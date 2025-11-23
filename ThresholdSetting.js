const mongoose = require('mongoose');

const thresholdSettingSchema = new mongoose.Schema({
  warehouse_id: { type: String, required: true },
  node_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Node', required: true },
  sensor_name: String,
  sensor_type: String,
  min_value: Number,
  max_value: Number,
  created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ThresholdSetting', thresholdSettingSchema);
