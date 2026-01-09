const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");

// ⚡ FIXED SCHEMA — Stores EXACT ESP32 payload
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

    Timestamp: String,                // Keep ORIGINAL string
    receivedAt: { type: Date },       // REAL time of storage
  },
  { collection: "masterdatas" }
);

const MasterData = mongoose.model("MasterData", masterDataSchema);

/* ----------------------------------------------------
    STORE INCOMING ESP32 DATA
---------------------------------------------------- */
router.post("/", async (req, res) => {
  try {
    const body = req.body;

    const entry = new MasterData({
      ...body,
      receivedAt: new Date(),
    });

    await entry.save();

    res.status(201).json({ message: "Stored" });
  } catch (err) {
    console.log("Masterdata POST error:", err);
    res.status(500).json({ error: "DB Error", details: err });
  }
});

/* ----------------------------------------------------
    FETCH MASTERDATA
    Supports:
    - ?limit=200
    - ?nodeId=1102
---------------------------------------------------- */
router.get("/", async (req, res) => {
  try {
    let query = {};

    if (req.query.nodeId) {
      query.NodeID = Number(req.query.nodeId);
    }

    const limit = Number(req.query.limit || 500);

    const rows = await MasterData.find(query)
      .sort({ receivedAt: -1 })
      .limit(limit);

    res.json(rows);
  } catch (error) {
    console.error("Error fetching master data:", error);
    res.status(500).json({ message: "Error fetching data", error });
  }
});

module.exports = router;
