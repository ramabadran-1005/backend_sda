const mongoose = require('mongoose');

const nodeSchema = new mongoose.Schema({
  slot_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Slot', required: true },
  warehouse_id: { type: String, required: true },
  node_type: { type: String, enum: ['gas', 'co2'], required: true },
  node_identifier: { type: String, required: true, unique: true }, // e.g., NW0123S05001
  node_name: { type: String, required: true, unique: true } // Friendly name
});

module.exports = mongoose.model('Node', nodeSchema);
