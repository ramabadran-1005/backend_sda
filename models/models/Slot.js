const mongoose = require('mongoose');

const slotSchema = new mongoose.Schema({
  warehouse_id: { type: String, required: true }, // FK to user_profiles or pre_deployment
  slot_name: { type: String, required: true },
  total_nodes: { type: Number, required: true },
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Slot', slotSchema);
