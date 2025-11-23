const mongoose = require('mongoose');

const alertSchema = new mongoose.Schema({
  timestamp: { type: Date, required: true },
  node_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Node', required: true },
  warehouse_id: { type: String, ref: 'UserProfile', required: true },
  alert_type: String, // 'threshold_breach', 'node_failure', etc.
  sensor_name: String,
  actual_value: Number,
  status: String // 'pending', 'resolved'
});

module.exports = mongoose.model('Alert', alertSchema);
