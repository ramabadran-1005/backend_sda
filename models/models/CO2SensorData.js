const mongoose = require('mongoose');

const co2SensorDataSchema = new mongoose.Schema({
  timestamp: { type: Date, default: Date.now },
  node_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Node', required: true },
  slot_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Slot', required: true },
  warehouse_id: { type: String, required: true },
  sensor_value_1: Number,
  sensor_value_2: Number,
  sensor_value_3: Number
});

module.exports = mongoose.model('CO2SensorData', co2SensorDataSchema);
