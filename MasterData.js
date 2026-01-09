const mongoose = require("mongoose");

const masterDataSchema = new mongoose.Schema(
  {
    NodeID: Number,

    TGS2620: Number,
    TGS2602: Number,
    TGS2600: Number,

    Drift2620: Number,
    Drift2602: Number,
    Drift2600: Number,

    Var2620: Number,
    Var2602: Number,
    Var2600: Number,

    Flat2620: Number,
    Flat2602: Number,
    Flat2600: Number,

    Uptime_sec: Number,
    Jitter_ms: Number,
    RSSI_dBm: Number,
    CPU_Temp_C: Number,
    FreeHeap_bytes: Number,

    Timestamp: String,

    receivedAt: {
      type: Date,
      default: Date.now,
    }
  },
  { collection: "masterdatas" }
);

module.exports = mongoose.model("MasterData", masterDataSchema);
