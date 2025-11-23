const express = require('express');
const router = express.Router();
const Slot = require('../models/Slot');

// Create Slot
router.post('/create', async (req, res) => {
  try {
    const { warehouse_id, slot_name, total_nodes } = req.body;
    const slot = new Slot({ warehouse_id, slot_name, total_nodes });
    await slot.save();
    res.status(201).json({ message: '✅ Slot created', slot });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
