const express = require('express');
const router = express.Router();
const PreDeployment = require('../models/PreDeployment');

router.post('/register', async (req, res) => {
  try {
    const { warehouse_id, warehouse_name, total_slots } = req.body;
    const warehouse = new PreDeployment({ warehouse_id, warehouse_name, total_slots });
    await warehouse.save();
    res.status(201).json({ message: '✅ Warehouse registered', warehouse });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

router.get('/', async (req, res) => {
  try {
    const warehouses = await PreDeployment.find();
    res.json(warehouses);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
