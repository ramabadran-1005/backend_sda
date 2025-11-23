// routes/masterDataRoutes.js
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

// ✅ Define Schema (match your MongoDB collection 'masterdatas')
const masterDataSchema = new mongoose.Schema({
  timestamp: { type: Date },
  temperature: { type: Number },
  humidity: { type: Number },
  co2: { type: Number },
  status: { type: String }
}, { collection: 'masterdatas' });  // <== important!

const MasterData = mongoose.model('MasterData', masterDataSchema);

// ✅ GET route
router.get('/', async (req, res) => {
  try {
    const data = await MasterData.find().sort({ timestamp: -1 }).limit(20);
    res.json(data);
  } catch (error) {
    console.error('Error fetching master data:', error);
    res.status(500).json({ message: 'Error fetching data', error });
  }
});

module.exports = router;
