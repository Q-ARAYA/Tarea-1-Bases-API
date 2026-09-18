const express = require('express');
const cors = require('cors');
const { getPool, sql } = require('./db');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// all of this endpoint uses the sp but with synonyms

// basic select, just one table 
app.get('/api/products', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute('syn_gp');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// select but now with join 
app.get('/api/products/with-category', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute('syn_gpc');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// insert
app.post('/api/products', async (req, res) => {
  try {
    const { name, productNumber, listPrice, subcategoryId } = req.body;
    const pool = await getPool();
    const result = await pool.request()
      .input('Name', sql.NVarChar(50), name)
      .input('ProductNumber', sql.NVarChar(25), productNumber)
      .input('ListPrice', sql.Money, listPrice)
      .input('ProductSubcategoryID', sql.Int, subcategoryId || null)
      .execute('syn_ip');
    res.status(201).json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// update
app.put('/api/products/:id', async (req, res) => {
  try {
    const { name, listPrice } = req.body;
    const pool = await getPool();
    await pool.request()
      .input('ProductID', sql.Int, req.params.id)
      .input('Name', sql.NVarChar(50), name)
      .input('ListPrice', sql.Money, listPrice)
      .execute('syn_up');
    res.json({ message: 'Producto actualizado' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// delete
app.delete('/api/products/:id', async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input('ProductID', sql.Int, req.params.id)
      .execute('syn_dp');
    res.json({ message: 'Producto eliminado' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`API corriendo en http://localhost:${PORT}`));