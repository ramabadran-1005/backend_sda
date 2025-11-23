const mongoose = require('mongoose');

const warehouseSchema = new mongoose.Schema({
  warehouse_id: { type: String, required: true, unique: true }, // legacy ID if needed
  warehouse_name: { type: String, required: true },
  total_slots: { type: Number, default: 0 },
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Warehouse', warehouseSchema);
