const express = require('express');
const router = express.Router();
const GasSensorData = require('../models/GasSensorData');

// POST: Add new gas sensor data
router.post('/', async (req, res) => {
  try {
    const data = new GasSensorData(req.body);
    await data.save();
    res.status(201).json({ message: '✅ Gas data saved', data });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Optional: GET all gas data
router.get('/', async (req, res) => {
  try {
    const allData = await GasSensorData.find();
    res.json(allData);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
