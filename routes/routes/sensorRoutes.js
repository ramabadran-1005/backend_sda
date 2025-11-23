// routes/sensorRoutes.js
const express = require('express');
const SensorData = require('../models/SensorData');

const router = express.Router();

// POST - receive data from ESP32
router.post('/data', async (req, res) => {
  try {
    const { nodeId, warehouseId, slotId, TGS2620, TGS2602, TGS2600 } = req.body;

    if (!nodeId || TGS2620 == null || TGS2602 == null || TGS2600 == null) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    const newData = new SensorData({
      nodeId,
      warehouseId,
      slotId,
      TGS2620,
      TGS2602,
      TGS2600
    });

    await newData.save();
    res.json({ success: true, message: 'Sensor data saved successfully' });

  } catch (error) {
    console.error('❌ Error saving sensor data:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// GET - latest readings for all nodes
router.get('/latest', async (req, res) => {
  try {
    const latestData = await SensorData.aggregate([
      { $sort: { timestamp: -1 } },
      { $group: { _id: "$nodeId", latest: { $first: "$$ROOT" } } }
    ]);
    res.json({ success: true, data: latestData });
  } catch (error) {
    console.error('❌ Error fetching latest data:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
