const express = require("express");
const router = express.Router();
const MasterData = require("../models/MasterData"); // same schema file

router.get("/", async (req, res) => {
  try {
    const oneMinuteAgo = Date.now() - 60000;

    const rows = await MasterData.find({
      receivedAt: { $gte: new Date(oneMinuteAgo) },
    }).sort({ receivedAt: -1 });

    const map = {};

    rows.forEach((r) => {
      map[r.NodeID] = r.receivedAt;
    });

    const result = Object.keys(map).map((id) => ({
      nodeId: id,
      lastSeen: map[id],
    }));

    res.json(result);
  } catch (err) {
    console.log("Live nodes error:", err);
    res.status(500).json({ error: "Error fetching live nodes" });
  }
});

module.exports = router;
