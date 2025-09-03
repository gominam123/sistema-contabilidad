const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public')); // Serve static files (e.g., your HTML)

// Database connection configuration
const dbConfig = {
    host: 'localhost',
    port: 3306,
    user: 'root', // Replace with your MySQL user
    password: '', // Replace with your MySQL password
    database: 'sistema_contable1'
};

// Create a connection pool
const pool = mysql.createPool(dbConfig);

// Test database connection
async function testConnection() {
    try {
        const connection = await pool.getConnection();
        console.log('Connected to MySQL database');
        connection.release();
    } catch (err) {
        console.error('Database connection error:', err);
    }
}
testConnection();

// Get company information
app.get('/api/empresa', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM Empresa WHERE empresa_id = ?', [1]);
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Empresa no encontrada' });
        }
        res.json(rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error al obtener datos de la empresa' });
    }
});

// Update company information
app.put('/api/empresa', async (req, res) => {
    const { nombre, representante, nit, direccion, telefono, fecha } = req.body;
    try {
        await pool.query(
            'UPDATE Empresa SET nombre = ?, razon_social = ?, representante = ?, nit = ?, direccion = ?, telefono = ? WHERE empresa_id = ?',
            [nombre, nombre, representante, nit, direccion, telefono, 1]
        );
        res.json({ message: 'Empresa actualizada correctamente' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error al actualizar datos de la empresa' });
    }
});

// Get balance data
app.get('/api/balance', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT c.nombre, dc.debe AS monto, t.nombre AS tipo
            FROM Detalle_Comprobante dc
            JOIN Cuenta c ON dc.cuenta_id = c.cuenta_id
            JOIN Tipo_Cuenta t ON c.tipo_cuenta_id = t.tipo_cuenta_id
            WHERE dc.comprobante_id = ?
        `, [1]);
        
        const balance = {
            activoCirculante: [],
            activoNoCirculante: [],
            pasivoCirculante: [],
            pasivoNoCirculante: [],
            patrimonio: []
        };

        rows.forEach(row => {
            if (row.tipo === 'Activo') {
                if (row.nombre.includes('CORRIENTE')) {
                    balance.activoCirculante.push({ cuenta: row.nombre, monto: row.monto });
                } else {
                    balance.activoNoCirculante.push({ cuenta: row.nombre, monto: row.monto });
                }
            } else if (row.tipo === 'Pasivo') {
                if (row.nombre.includes('CORRIENTE')) {
                    balance.pasivoCirculante.push({ cuenta: row.nombre, monto: row.monto });
                } else {
                    balance.pasivoNoCirculante.push({ cuenta: row.nombre, monto: row.monto });
                }
            } else if (row.tipo === 'Patrimonio') {
                balance.patrimonio.push({ cuenta: row.nombre, monto: row.monto });
            }
        });

        res.json(balance);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error al obtener datos del balance' });
    }
});

// Save balance data
app.post('/api/balance', async (req, res) => {
    const { activoCirculante, activoNoCirculante, pasivoCirculante, pasivoNoCirculante, patrimonio } = req.body;
    try {
        // Start transaction
        const connection = await pool.getConnection();
        await connection.beginTransaction();

        try {
            // Clear existing details for comprobante_id = 1
            await connection.query('DELETE FROM Detalle_Comprobante WHERE comprobante_id = ?', [1]);

            // Insert new details
            const insertDetails = async (accounts, tipo) => {
                for (const account of accounts) {
                    const [cuenta] = await connection.query(
                        'SELECT cuenta_id FROM Cuenta WHERE nombre = ? AND empresa_id = ?',
                        [account.cuenta, 1]
                    );
                    if (cuenta.length > 0) {
                        await connection.query(
                            'INSERT INTO Detalle_Comprobante (comprobante_id, cuenta_id, debe, haber, glosa) VALUES (?, ?, ?, ?, ?)',
                            [1, cuenta[0].cuenta_id, tipo === 'Activo' ? account.monto : 0, tipo === 'Patrimonio' ? account.monto : 0, `Apertura ${account.cuenta}`]
                        );
                    }
                }
            };

            await insertDetails(activoCirculante, 'Activo');
            await insertDetails(activoNoCirculante, 'Activo');
            await insertDetails(pasivoCirculante, 'Pasivo');
            await insertDetails(pasivoNoCirculante, 'Pasivo');
            await insertDetails(patrimonio, 'Patrimonio');

            // Update Comprobante totals
            const [activoRows] = await connection.query(
                'SELECT SUM(debe) as total_debe FROM Detalle_Comprobante WHERE comprobante_id = ?',
                [1]
            );
            const [patrimonioRows] = await connection.query(
                'SELECT SUM(haber) as total_haber FROM Detalle_Comprobante WHERE comprobante_id = ?',
                [1]
            );
            await connection.query(
                'UPDATE Comprobante SET total_debe = ?, total_haber = ? WHERE comprobante_id = ?',
                [activoRows[0].total_debe || 0, patrimonioRows[0].total_haber || 0, 1]
            );

            await connection.commit();
            res.json({ message: 'Balance guardado correctamente' });
        } catch (err) {
            await connection.rollback();
            throw err;
        } finally {
            connection.release();
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error al guardar datos del balance' });
    }
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});