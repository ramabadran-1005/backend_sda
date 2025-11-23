const express = require('express');
const router = express.Router();
const DeviceControl = require('../models/DeviceControl');

// POST – send a control command to a device
router.post('/', async (req, res) => {
  try {
    const command = new DeviceControl(req.body);
    await command.save();
    res.status(201).json(command);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET – list all device control commands
router.get('/', async (req, res) => {
  try {
    const commands = await DeviceControl.find().populate('node_id');
    res.json(commands);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET – commands for a specific node
router.get('/node/:node_id', async (req, res) => {
  try {
    const commands = await DeviceControl.find({ node_id: req.params.node_id });
    res.json(commands);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
