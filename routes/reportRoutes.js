const express = require('express');
const router = express.Router();
const Report = require('../models/Report');

// POST – generate a report (store metadata)
router.post('/', async (req, res) => {
  try {
    const report = new Report(req.body);
    await report.save();
    res.status(201).json(report);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET – all reports
router.get('/', async (req, res) => {
  try {
    const reports = await Report.find().populate('generated_by');
    res.json(reports);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET – report by warehouse
router.get('/warehouse/:warehouse_id', async (req, res) => {
  try {
    const reports = await Report.find({ warehouse_id: req.params.warehouse_id });
    res.json(reports);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
