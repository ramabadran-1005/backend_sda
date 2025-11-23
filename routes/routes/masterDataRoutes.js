const express = require('express');
const router = express.Router();
const MasterData = require('../models/MasterDataModel');

// ✅ Quick test route
router.get('/test', (req, res) => res.json({ ok: true, message: 'MasterData route working' }));

// ✅ Fetch recent data
router.get('/', async (req, res) => {
  try {
    const data = await MasterData.find().sort({ Timestamp: -1 }).limit(50);
    res.json(data);
  } catch (err) {
    console.error('Error fetching MasterData:', err);
    res.status(500).json({ error: 'Failed to fetch data' });
  }
});

module.exports = router;
