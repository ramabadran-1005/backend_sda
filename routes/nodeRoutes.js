const express = require('express');
const router = express.Router();
const Node = require('../models/Node');

// Register a node
router.post('/create', async (req, res) => {
  try {
    const { slot_id, warehouse_id, node_type, node_identifier, node_name } = req.body;
    const node = new Node({ slot_id, warehouse_id, node_type, node_identifier, node_name });
    await node.save();
    res.status(201).json({ message: '✅ Node registered', node });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
