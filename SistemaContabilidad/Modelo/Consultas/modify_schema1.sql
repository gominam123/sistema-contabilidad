CREATE DATABASE sistema_contable1;
USE sistema_contable1;

-- Tablas Maestras
CREATE TABLE Empresa (
    empresa_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    razon_social VARCHAR(100),
    representante VARCHAR(100),
    nit VARCHAR(20) UNIQUE NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    email VARCHAR(100),
    logo BLOB,
    estado ENUM('ACTIVA', 'INACTIVA') DEFAULT 'ACTIVA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_empresa_nit (nit)
) ENGINE=InnoDB;

CREATE TABLE Periodo_Contable (
    periodo_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('ABIERTO', 'CERRADO') DEFAULT 'ABIERTO',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_periodo_empresa (empresa_id, nombre),
    INDEX idx_periodo_empresa (empresa_id)
) ENGINE=InnoDB;

CREATE TABLE Moneda (
    moneda_id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(3) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    simbolo VARCHAR(5),
    decimales TINYINT DEFAULT 2,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_moneda_codigo (codigo)
) ENGINE=InnoDB;

-- Plan de Cuentas
CREATE TABLE Tipo_Cuenta (
    tipo_cuenta_id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    naturaleza ENUM('DEUDORA', 'ACREEDORA') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tipo_cuenta_codigo (codigo)
) ENGINE=InnoDB;

CREATE TABLE Cuenta (
    cuenta_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    codigo VARCHAR(20) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    tipo_cuenta_id INT NOT NULL,
    moneda_id INT NOT NULL,
    cuenta_padre_id INT NULL,
    nivel TINYINT NOT NULL,
    es_analitica BOOLEAN DEFAULT FALSE,
    permite_movimientos BOOLEAN DEFAULT TRUE,
    estado ENUM('ACTIVA', 'INACTIVA') DEFAULT 'ACTIVA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    FOREIGN KEY (tipo_cuenta_id) REFERENCES Tipo_Cuenta(tipo_cuenta_id) ON DELETE RESTRICT,
    FOREIGN KEY (moneda_id) REFERENCES Moneda(moneda_id) ON DELETE RESTRICT,
    FOREIGN KEY (cuenta_padre_id) REFERENCES Cuenta(cuenta_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_cuenta_empresa_codigo (empresa_id, codigo),
    INDEX idx_cuenta_empresa (empresa_id),
    INDEX idx_cuenta_codigo (codigo)
) ENGINE=InnoDB;

-- Documentos Contables
CREATE TABLE Tipo_Comprobante (
    tipo_comprobante_id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200),
    afecta_libros BOOLEAN DEFAULT TRUE,
    estado ENUM('ACTIVO', 'INACTIVO') DEFAULT 'ACTIVO',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tipo_comprobante_codigo (codigo)
) ENGINE=InnoDB;

CREATE TABLE Comprobante (
    comprobante_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    periodo_id INT NOT NULL,
    tipo_comprobante_id INT NOT NULL,
    numero VARCHAR(20) NOT NULL,
    fecha DATE NOT NULL,
    glosa VARCHAR(200),
    estado ENUM('BORRADOR', 'APROBADO', 'ANULADO') DEFAULT 'BORRADOR',
    total_debe DECIMAL(18, 2) DEFAULT 0.00,
    total_haber DECIMAL(18, 2) DEFAULT 0.00,
    usuario_creacion VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    FOREIGN KEY (periodo_id) REFERENCES Periodo_Contable(periodo_id) ON DELETE RESTRICT,
    FOREIGN KEY (tipo_comprobante_id) REFERENCES Tipo_Comprobante(tipo_comprobante_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_comprobante_empresa_tipo_numero (empresa_id, tipo_comprobante_id, numero),
    INDEX idx_comprobante_empresa (empresa_id),
    INDEX idx_comprobante_periodo (periodo_id)
) ENGINE=InnoDB;

CREATE TABLE Detalle_Comprobante (
    detalle_id INT PRIMARY KEY AUTO_INCREMENT,
    comprobante_id INT NOT NULL,
    cuenta_id INT NOT NULL,
    debe DECIMAL(18, 2) DEFAULT 0.00,
    haber DECIMAL(18, 2) DEFAULT 0.00,
    glosa VARCHAR(200),
    referencia VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (comprobante_id) REFERENCES Comprobante(comprobante_id) ON DELETE CASCADE,
    FOREIGN KEY (cuenta_id) REFERENCES Cuenta(cuenta_id) ON DELETE RESTRICT,
    INDEX idx_detalle_comprobante_id (comprobante_id),
    INDEX idx_detalle_cuenta_id (cuenta_id)
) ENGINE=InnoDB;

-- Inventario y Activos Fijos
CREATE TABLE Articulo (
    articulo_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    codigo VARCHAR(20) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200),
    unidad_medida VARCHAR(20),
    tipo ENUM('BIEN', 'SERVICIO') DEFAULT 'BIEN',
    estado ENUM('ACTIVO', 'INACTIVO') DEFAULT 'ACTIVO',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_articulo_empresa_codigo (empresa_id, codigo),
    INDEX idx_articulo_empresa (empresa_id)
) ENGINE=InnoDB;

CREATE TABLE Kardex (
    kardex_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    articulo_id INT NOT NULL,
    fecha DATE NOT NULL,
    comprobante_id INT,
    tipo_movimiento ENUM('ENTRADA', 'SALIDA') NOT NULL,
    cantidad DECIMAL(12, 3) NOT NULL,
    costo_unitario DECIMAL(12, 2) NOT NULL,
    costo_total DECIMAL(18, 2) NOT NULL,
    saldo_cantidad DECIMAL(12, 3) NOT NULL,
    saldo_costo DECIMAL(18, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    FOREIGN KEY (articulo_id) REFERENCES Articulo(articulo_id) ON DELETE RESTRICT,
    FOREIGN KEY (comprobante_id) REFERENCES Comprobante(comprobante_id) ON DELETE SET NULL,
    INDEX idx_kardex_empresa (empresa_id),
    INDEX idx_kardex_articulo (articulo_id)
) ENGINE=InnoDB;

CREATE TABLE Activo_Fijo (
    activo_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    cuenta_id INT NOT NULL,
    codigo VARCHAR(20) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200),
    fecha_adquisicion DATE NOT NULL,
    costo_historico DECIMAL(18, 2) NOT NULL,
    valor_residual DECIMAL(18, 2) DEFAULT 0.00,
    vida_util INT NOT NULL,
    metodo_depreciacion ENUM('LINEAL', 'ACELERADA') DEFAULT 'LINEAL',
    estado ENUM('ACTIVO', 'BAJA', 'VENDIDO') DEFAULT 'ACTIVO',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    FOREIGN KEY (cuenta_id) REFERENCES Cuenta(cuenta_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_activo_empresa_codigo (empresa_id, codigo),
    INDEX idx_activo_empresa (empresa_id)
) ENGINE=InnoDB;

CREATE TABLE Depreciacion (
    depreciacion_id INT PRIMARY KEY AUTO_INCREMENT,
    activo_id INT NOT NULL,
    periodo_id INT NOT NULL,
    fecha DATE NOT NULL,
    monto_depreciacion DECIMAL(18, 2) NOT NULL,
    depreciacion_acumulada DECIMAL(18, 2) NOT NULL,
    valor_neto DECIMAL(18, 2) NOT NULL,
    comprobante_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (activo_id) REFERENCES Activo_Fijo(activo_id) ON DELETE RESTRICT,
    FOREIGN KEY (periodo_id) REFERENCES Periodo_Contable(periodo_id) ON DELETE RESTRICT,
    FOREIGN KEY (comprobante_id) REFERENCES Comprobante(comprobante_id) ON DELETE SET NULL,
    UNIQUE KEY uk_depreciacion_activo_periodo (activo_id, periodo_id),
    INDEX idx_depreciacion_activo (activo_id)
) ENGINE=InnoDB;

-- Impuestos
CREATE TABLE Impuesto (
    impuesto_id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    tasa DECIMAL(5, 2) NOT NULL,
    tipo ENUM('IVA', 'IT', 'IEHD', 'OTRO') NOT NULL,
    descripcion VARCHAR(200),
    estado ENUM('ACTIVO', 'INACTIVO') DEFAULT 'ACTIVO',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_impuesto_codigo (codigo)
) ENGINE=InnoDB;

CREATE TABLE Transaccion_Impuesto (
    transaccion_impuesto_id INT PRIMARY KEY AUTO_INCREMENT,
    comprobante_id INT NOT NULL,
    impuesto_id INT NOT NULL,
    base_imponible DECIMAL(18, 2) NOT NULL,
    monto_impuesto DECIMAL(18, 2) NOT NULL,
    tipo ENUM('DEBITO', 'CREDITO') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (comprobante_id) REFERENCES Comprobante(comprobante_id) ON DELETE CASCADE,
    FOREIGN KEY (impuesto_id) REFERENCES Impuesto(impuesto_id) ON DELETE RESTRICT,
    INDEX idx_transaccion_comprobante (comprobante_id)
) ENGINE=InnoDB;

-- Libros Oficiales
CREATE TABLE Libro_Diario (
    diario_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    periodo_id INT NOT NULL,
    fecha DATE NOT NULL,
    comprobante_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    FOREIGN KEY (periodo_id) REFERENCES Periodo_Contable(periodo_id) ON DELETE RESTRICT,
    FOREIGN KEY (comprobante_id) REFERENCES Comprobante(comprobante_id) ON DELETE CASCADE,
    UNIQUE KEY uk_diario_empresa_periodo_comprobante (empresa_id, periodo_id, comprobante_id),
    INDEX idx_diario_empresa (empresa_id),
    INDEX idx_diario_periodo (periodo_id)
) ENGINE=InnoDB;

CREATE TABLE Libro_Mayor (
    mayor_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    periodo_id INT NOT NULL,
    cuenta_id INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    saldo_inicial DECIMAL(18, 2) NOT NULL,
    debe DECIMAL(18, 2) DEFAULT 0.00,
    haber DECIMAL(18, 2) DEFAULT 0.00,
    saldo_final DECIMAL(18, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    FOREIGN KEY (periodo_id) REFERENCES Periodo_Contable(periodo_id) ON DELETE RESTRICT,
    FOREIGN KEY (cuenta_id) REFERENCES Cuenta(cuenta_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_mayor_empresa_periodo_cuenta (empresa_id, periodo_id, cuenta_id),
    INDEX idx_mayor_empresa (empresa_id),
    INDEX idx_mayor_periodo (periodo_id)
) ENGINE=InnoDB;

-- Estados Financieros
CREATE TABLE Balance_Comprobacion (
    balance_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    periodo_id INT NOT NULL,
    fecha DATE NOT NULL,
    estado ENUM('PRELIMINAR', 'DEFINITIVO') DEFAULT 'PRELIMINAR',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    FOREIGN KEY (periodo_id) REFERENCES Periodo_Contable(periodo_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_balance_empresa_periodo (empresa_id, periodo_id),
    INDEX idx_balance_empresa (empresa_id)
) ENGINE=InnoDB;

CREATE TABLE Detalle_Balance_Comprobacion (
    detalle_id INT PRIMARY KEY AUTO_INCREMENT,
    balance_id INT NOT NULL,
    cuenta_id INT NOT NULL,
    saldo_inicial DECIMAL(18, 2) NOT NULL,
    debe DECIMAL(18, 2) DEFAULT 0.00,
    haber DECIMAL(18, 2) DEFAULT 0.00,
    saldo_final DECIMAL(18, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (balance_id) REFERENCES Balance_Comprobacion(balance_id) ON DELETE CASCADE,
    FOREIGN KEY (cuenta_id) REFERENCES Cuenta(cuenta_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_detalle_balance_cuenta (balance_id, cuenta_id),
    INDEX idx_detalle_balance_id (balance_id)
) ENGINE=InnoDB;

CREATE TABLE Hoja_Trabajo (
    hoja_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    periodo_id INT NOT NULL,
    fecha DATE NOT NULL,
    estado ENUM('BORRADOR', 'APROBADO') DEFAULT 'BORRADOR',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    FOREIGN KEY (periodo_id) REFERENCES Periodo_Contable(periodo_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_hoja_empresa_periodo (empresa_id, periodo_id),
    INDEX idx_hoja_empresa (empresa_id)
) ENGINE=InnoDB;

CREATE TABLE Detalle_Hoja_Trabajo (
    detalle_id INT PRIMARY KEY AUTO_INCREMENT,
    hoja_id INT NOT NULL,
    cuenta_id INT NOT NULL,
    saldo_ajustado_debe DECIMAL(18, 2) DEFAULT 0.00,
    saldo_ajustado_haber DECIMAL(18, 2) DEFAULT 0.00,
    ajuste_debe DECIMAL(18, 2) DEFAULT 0.00,
    ajuste_haber DECIMAL(18, 2) DEFAULT 0.00,
    saldo_final_debe DECIMAL(18, 2) DEFAULT 0.00,
    saldo_final_haber DECIMAL(18, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hoja_id) REFERENCES Hoja_Trabajo(hoja_id) ON DELETE CASCADE,
    FOREIGN KEY (cuenta_id) REFERENCES Cuenta(cuenta_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_detalle_hoja_cuenta (hoja_id, cuenta_id),
    INDEX idx_detalle_hoja_id (hoja_id)
) ENGINE=InnoDB;

CREATE TABLE Estado_Resultados (
    estado_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    periodo_id INT NOT NULL,
    fecha DATE NOT NULL,
    estado ENUM('PRELIMINAR', 'DEFINITIVO') DEFAULT 'PRELIMINAR',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    FOREIGN KEY (periodo_id) REFERENCES Periodo_Contable(periodo_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_estado_empresa_periodo (empresa_id, periodo_id),
    INDEX idx_estado_empresa (empresa_id)
) ENGINE=InnoDB;

CREATE TABLE Detalle_Estado_Resultados (
    detalle_id INT PRIMARY KEY AUTO_INCREMENT,
    estado_id INT NOT NULL,
    cuenta_id INT NOT NULL,
    monto DECIMAL(18, 2) NOT NULL,
    tipo ENUM('INGRESO', 'COSTO', 'GASTO', 'OTRO') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (estado_id) REFERENCES Estado_Resultados(estado_id) ON DELETE CASCADE,
    FOREIGN KEY (cuenta_id) REFERENCES Cuenta(cuenta_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_detalle_estado_cuenta (estado_id, cuenta_id),
    INDEX idx_detalle_estado_id (estado_id)
) ENGINE=InnoDB;

CREATE TABLE Balance_General (
    balance_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    periodo_id INT NOT NULL,
    fecha DATE NOT NULL,
    estado ENUM('PRELIMINAR', 'DEFINITIVO') DEFAULT 'PRELIMINAR',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    FOREIGN KEY (periodo_id) REFERENCES Periodo_Contable(periodo_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_balance_general_empresa_periodo (empresa_id, periodo_id),
    INDEX idx_balance_general_empresa (empresa_id)
) ENGINE=InnoDB;

CREATE TABLE Detalle_Balance_General (
    detalle_id INT PRIMARY KEY AUTO_INCREMENT,
    balance_id INT NOT NULL,
    cuenta_id INT NOT NULL,
    monto DECIMAL(18, 2) NOT NULL,
    tipo ENUM('ACTIVO', 'PASIVO', 'PATRIMONIO') NOT NULL,
    subtipo ENUM('CORRIENTE', 'NO_CORRIENTE', 'OTRO') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (balance_id) REFERENCES Balance_General(balance_id) ON DELETE CASCADE,
    FOREIGN KEY (cuenta_id) REFERENCES Cuenta(cuenta_id) ON DELETE RESTRICT,
    UNIQUE KEY uk_detalle_balance_general_cuenta (balance_id, cuenta_id),
    INDEX idx_detalle_balance_general_id (balance_id)
) ENGINE=InnoDB;

-- Cierre Contable
CREATE TABLE Cierre_Contable (
    cierre_id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    periodo_id INT NOT NULL,
    fecha DATE NOT NULL,
    estado_cierre ENUM('EN_PROCESO', 'COMPLETADO', 'REVERTIDO') DEFAULT 'EN_PROCESO',
    balance_general_id INT,
    estado_resultados_id INT,
    usuario_cierre VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES Empresa(empresa_id) ON DELETE RESTRICT,
    FOREIGN KEY (periodo_id) REFERENCES Periodo_Contable(periodo_id) ON DELETE RESTRICT,
    FOREIGN KEY (balance_general_id) REFERENCES Balance_General(balance_id) ON DELETE SET NULL,
    FOREIGN KEY (estado_resultados_id) REFERENCES Estado_Resultados(estado_id) ON DELETE SET NULL,
    UNIQUE KEY uk_cierre_empresa_periodo (empresa_id, periodo_id),
    INDEX idx_cierre_empresa (empresa_id)
) ENGINE=InnoDB;

-- Datos iniciales
INSERT INTO Moneda (codigo, nombre, simbolo, decimales) VALUES 
('BOB', 'Boliviano', 'Bs.', 2),
('USD', 'Dólar Americano', '$', 2);

INSERT INTO Tipo_Cuenta (codigo, nombre, naturaleza) VALUES
('ACT', 'Activo', 'DEUDORA'),
('PAS', 'Pasivo', 'ACREEDORA'),
('PAT', 'Patrimonio', 'ACREEDORA'),
('ING', 'Ingresos', 'ACREEDORA'),
('COS', 'Costos', 'DEUDORA'),
('GAS', 'Gastos', 'DEUDORA');

INSERT INTO Tipo_Comprobante (codigo, nombre, afecta_libros) VALUES
('DIAR', 'Diario', TRUE),
('COMP', 'Compra', TRUE),
('VENT', 'Venta', TRUE),
('AJUS', 'Ajuste', TRUE),
('CIER', 'Cierre', TRUE);

INSERT INTO Impuesto (codigo, nombre, tasa, tipo) VALUES
('IVA13', 'IVA 13%', 13.00, 'IVA'),
('IVA0', 'IVA 0%', 0.00, 'IVA'),
('IVAEX', 'IVA Exento', 0.00, 'IVA');

-- Datos de ejemplo para la empresa LOS TRAVIESOS
INSERT INTO Empresa (nombre, razon_social, representante, nit, direccion, telefono) VALUES
('LOS TRAVIESOS', 'LOS TRAVIESOS S.R.L.', 'Sr. Juan Marcelo Martínez Mamani', '568791012', 
 'Calle Marineros esquina Caballeros Nº 245', '4571022');

-- Crear periodo contable
INSERT INTO Periodo_Contable (empresa_id, nombre, fecha_inicio, fecha_fin) VALUES
(1, 'Gestión 2024', '2024-01-01', '2024-12-31');

-- Plan de cuentas para LOS TRAVIESOS
INSERT INTO Cuenta (empresa_id, codigo, nombre, tipo_cuenta_id, moneda_id, cuenta_padre_id, nivel, permite_movimientos) VALUES
-- Activos
(1, '1', 'ACTIVO', 1, 1, NULL, 1, FALSE),
(1, '1.1', 'ACTIVO CORRIENTE', 1, 1, 1, 2, FALSE),
(1, '1.1.1', 'Caja Moneda Nacional', 1, 1, 2, 3, TRUE),
(1, '1.1.2', 'Banco Moneda Nacional', 1, 1, 2, 3, TRUE),
(1, '1.1.3', 'Almacén de Mercaderías', 1, 1, 2, 3, TRUE),
(1, '1.1.4', 'Crédito Fiscal IVA', 1, 1, 2, 3, TRUE),
(1, '1.2', 'ACTIVO NO CORRIENTE', 1, 1, 1, 2, FALSE),
(1, '1.2.1', 'Terrenos', 1, 1, 7, 3, TRUE),
(1, '1.2.2', 'Motocicleta', 1, 1, 7, 3, TRUE),
(1, '1.2.3', 'Equipo de Computación', 1, 1, 7, 3, TRUE),
-- Pasivos
(1, '2', 'PASIVO', 2, 1, NULL, 1, FALSE),
(1, '2.1', 'PASIVO CORRIENTE', 2, 1, 11, 2, FALSE),
(1, '2.1.1', 'Cuentas por Pagar', 2, 1, 12, 3, TRUE),
(1, '2.1.2', 'Débito Fiscal IVA', 2, 1, 12, 3, TRUE),
(1, '2.2', 'PASIVO NO CORRIENTE', 2, 1, 11, 2, FALSE),
(1, '2.2.1', 'Depreciación Acumulada Vehículos', 2, 1, 15, 3, TRUE),
(1, '2.2.2', 'Depreciación Acumulada Equipo de Computación', 2, 1, 15, 3, TRUE),
-- Patrimonio
(1, '3', 'PATRIMONIO', 3, 1, NULL, 1, FALSE),
(1, '3.1', 'Capital', 3, 1, 18, 2, TRUE),
(1, '3.2', 'Ajustes de Capital', 3, 1, 18, 2, TRUE),
(1, '3.3', 'Resultados de Gestión', 3, 1, 18, 2, TRUE);

-- Balance de Apertura
INSERT INTO Comprobante (empresa_id, periodo_id, tipo_comprobante_id, numero, fecha, glosa, estado, total_debe, total_haber) VALUES
(1, 1, 1, 'APE-2024-001', '2024-01-01', 'Asiento de apertura ejercicio 2024', 'APROBADO', 1519000.00, 1519000.00);

INSERT INTO Detalle_Comprobante (comprobante_id, cuenta_id, debe, haber, glosa) VALUES
-- Activos
(1, 3, 990000.00, 0.00, 'Apertura caja'),
(1, 4, 220000.00, 0.00, 'Apertura banco'),
(1, 8, 300000.00, 0.00, 'Apertura terrenos'),
(1, 10, 9000.00, 0.00, 'Apertura equipo computación'),
-- Patrimonio
(1, 19, 0.00, 1519000.00, 'Apertura capital');

INSERT INTO Libro_Diario (empresa_id, periodo_id, fecha, comprobante_id) VALUES
(1, 1, '2024-01-01', 1);