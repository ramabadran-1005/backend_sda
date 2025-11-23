const mongoose = require('mongoose');

const gasSensorDataSchema = new mongoose.Schema({
  timestamp: { type: Date, required: true },
  node_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Node', required: true },
  slot_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Slot', required: true },
  warehouse_id: { type: String, ref: 'UserProfile', required: true },
  sensor_value_1: Number,
  sensor_value_2: Number,
  sensor_value_3: Number
});

module.exports = mongoose.model('GasSensorData', gasSensorDataSchema);
