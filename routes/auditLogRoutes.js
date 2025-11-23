const express = require('express');
const router = express.Router();
const AuditLog = require('../models/AuditLog');

// POST – record an action
router.post('/', async (req, res) => {
  try {
    const log = new AuditLog(req.body);
    await log.save();
    res.status(201).json(log);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET – fetch all logs
router.get('/', async (req, res) => {
  try {
    const logs = await AuditLog.find().populate('user_id');
    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET – logs by user
router.get('/user/:user_id', async (req, res) => {
  try {
    const logs = await AuditLog.find({ user_id: req.params.user_id });
    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
