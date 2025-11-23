const mongoose = require('mongoose');

const nodeSchema = new mongoose.Schema({
  slotId: { type: mongoose.Schema.Types.ObjectId, ref: 'Slot', required: true },
  warehouseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Warehouse', required: true },
  node_type: String,
  node_identifier: String,
  node_name: String,
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Node', nodeSchema);
