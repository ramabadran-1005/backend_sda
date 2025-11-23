const express = require('express');
const router = express.Router();
const CO2SensorData = require('../models/CO2SensorData');

// POST: Add new CO₂ sensor data
router.post('/', async (req, res) => {
  try {
    const data = new CO2SensorData(req.body);
    await data.save();
    res.status(201).json({ message: '✅ CO₂ data saved', data });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Optional: GET all CO₂ data
router.get('/', async (req, res) => {
  try {
    const allData = await CO2SensorData.find();
    res.json(allData);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
