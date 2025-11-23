const express = require('express');
const router = express.Router();
const ThresholdSetting = require('../models/ThresholdSetting');

// POST – create threshold
router.post('/', async (req, res) => {
  try {
    const setting = new ThresholdSetting(req.body);
    await setting.save();
    res.status(201).json(setting);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET – fetch all thresholds
router.get('/', async (req, res) => {
  try {
    const settings = await ThresholdSetting.find();
    res.json(settings);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET – by node_id
router.get('/:node_id', async (req, res) => {
  try {
    const setting = await ThresholdSetting.find({ node_id: req.params.node_id });
    res.json(setting);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT – update by ID
router.put('/:id', async (req, res) => {
  try {
    const updated = await ThresholdSetting.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE – delete by ID
router.delete('/:id', async (req, res) => {
  try {
    await ThresholdSetting.findByIdAndDelete(req.params.id);
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
