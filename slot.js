const mongoose = require('mongoose');

const slotSchema = new mongoose.Schema({
  warehouseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Warehouse', required: true },
  slot_name: { type: String, required: true },
  total_nodes: { type: Number, default: 0 },
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Slot', slotSchema);
