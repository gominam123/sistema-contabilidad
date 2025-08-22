ALTER TABLE Comprobante
    MODIFY COLUMN total_debe INT NOT NULL DEFAULT 0,
    MODIFY COLUMN total_haber INT NOT NULL DEFAULT 0;

ALTER TABLE Detalle_Comprobante
    MODIFY COLUMN debe INT NOT NULL DEFAULT 0,
    MODIFY COLUMN haber INT NOT NULL DEFAULT 0;

ALTER TABLE Kardex
    MODIFY COLUMN cantidad INT NOT NULL,
    MODIFY COLUMN costo_unitario INT NOT NULL,
    MODIFY COLUMN costo_total INT NOT NULL,
    MODIFY COLUMN saldo_cantidad INT NOT NULL,
    MODIFY COLUMN saldo_costo INT NOT NULL;

ALTER TABLE Activo_Fijo
    MODIFY COLUMN costo_historico INT NOT NULL,
    MODIFY COLUMN valor_residual INT NOT NULL DEFAULT 0;

ALTER TABLE Depreciacion
    MODIFY COLUMN monto_depreciacion INT NOT NULL,
    MODIFY COLUMN depreciacion_acumulada INT NOT NULL,
    MODIFY COLUMN valor_neto INT NOT NULL;

ALTER TABLE Transaccion_Impuesto
    MODIFY COLUMN base_imponible INT NOT NULL,
    MODIFY COLUMN monto_impuesto INT NOT NULL;

ALTER TABLE Libro_Mayor
    MODIFY COLUMN saldo_inicial INT NOT NULL,
    MODIFY COLUMN debe INT NOT NULL DEFAULT 0,
    MODIFY COLUMN haber INT NOT NULL DEFAULT 0,
    MODIFY COLUMN saldo_final INT NOT NULL;

ALTER TABLE Detalle_Balance_Comprobacion
    MODIFY COLUMN saldo_inicial INT NOT NULL,
    MODIFY COLUMN debe INT NOT NULL DEFAULT 0,
    MODIFY COLUMN haber INT NOT NULL DEFAULT 0,
    MODIFY COLUMN saldo_final INT NOT NULL;

ALTER TABLE Detalle_Hoja_Trabajo
    MODIFY COLUMN saldo_ajustado_debe INT NOT NULL DEFAULT 0,
    MODIFY COLUMN saldo_ajustado_haber INT NOT NULL DEFAULT 0,
    MODIFY COLUMN ajuste_debe INT NOT NULL DEFAULT 0,
    MODIFY COLUMN ajuste_haber INT NOT NULL DEFAULT 0,
    MODIFY COLUMN saldo_final_debe INT NOT NULL DEFAULT 0,
    MODIFY COLUMN saldo_final_haber INT NOT NULL DEFAULT 0;

ALTER TABLE Detalle_Estado_Resultados
    MODIFY COLUMN monto INT NOT NULL;

ALTER TABLE Detalle_Balance_General
    MODIFY COLUMN monto INT NOT NULL;