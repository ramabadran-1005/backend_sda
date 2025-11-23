const mongoose = require('mongoose');

const nodeHealthSchema = new mongoose.Schema({
  node_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Node' },
  timestamp: { type: Date, default: Date.now },
  uptime_percentage: Number,
  packet_loss: Number,
  jitter: Number,
  rssi: Number,
  cpu_temp: Number,
  free_heap_memory: Number
});

module.exports = mongoose.model('NodeHealth', nodeHealthSchema);
