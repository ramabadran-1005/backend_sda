const express = require('express');
const router = express.Router();
const NodeHealth = require('../models/NodeHealth');

// POST – add node health entry
router.post('/', async (req, res) => {
  try {
    const health = new NodeHealth(req.body);
    await health.save();
    res.status(201).json(health);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET – all health logs
router.get('/', async (req, res) => {
  try {
    const all = await NodeHealth.find().populate('node_id');
    res.json(all);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET – latest health for specific node
router.get('/latest/:node_id', async (req, res) => {
  try {
    const latest = await NodeHealth.findOne({ node_id: req.params.node_id })
      .sort({ timestamp: -1 });
    res.json(latest);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
