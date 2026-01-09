import React, { useEffect, useState } from "react";
import Grid from "@mui/material/Grid";
import Paper from "@mui/material/Paper";
import Typography from "@mui/material/Typography";
import SensorsIcon from "@mui/icons-material/Sensors";
import WarningIcon from "@mui/icons-material/Warning";
import AssessmentIcon from "@mui/icons-material/Assessment";
import ArticleIcon from "@mui/icons-material/Article";
import FlashOnIcon from "@mui/icons-material/FlashOn";
import { useNavigate } from "react-router-dom";

import {
  getMasterdata,
  getAlerts,
  getPredictionsLatest,
  getLiveNodes
} from "../services/api";

function StatCard({ title, value, icon, color, onClick }) {
  return (
    <Paper
      sx={{
        p: 2,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 1,
        cursor: onClick ? "pointer" : "default",
      }}
      onClick={onClick}
    >
      <div style={{ fontSize: 34, color }}>{icon}</div>
      <Typography variant="h5" sx={{ fontWeight: 700 }}>
        {value}
      </Typography>
      <Typography variant="body2" color="text.secondary">
        {title}
      </Typography>
    </Paper>
  );
}

export default function Overview() {
  const [master, setMaster] = useState([]);
  const [alerts, setAlerts] = useState([]);
  const [preds, setPreds] = useState([]);
  const [liveCount, setLiveCount] = useState(0);
  const navigate = useNavigate();

  async function load() {
    const [m, a, p, live] = await Promise.all([
      getMasterdata(),
      getAlerts(),
      getPredictionsLatest(),
      getLiveNodes(60),
    ]);

    setMaster(m || []);
    setAlerts(a || []);
    setPreds(p || []);
    setLiveCount(live?.count || 0);
  }

  useEffect(() => {
    load();
    const interval = setInterval(load, 3000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ padding: 24 }}>
      <Grid container spacing={2}>
        <Grid item xs={12} md={3}>
          <StatCard
            title="Master Data Records"
            value={master.length}
            icon={<SensorsIcon />}
            color="#184d19"
          />
        </Grid>

        <Grid item xs={12} md={3}>
          <StatCard
            title="Alerts"
            value={alerts.length}
            icon={<WarningIcon />}
            color="#d32f2f"
          />
        </Grid>

        <Grid item xs={12} md={3}>
          <StatCard
            title="Latest Predictions"
            value={preds.length}
            icon={<AssessmentIcon />}
            color="#ff9800"
          />
        </Grid>

        <Grid item xs={12} md={3}>
          <StatCard
            title="Reports"
            value={0}
            icon={<ArticleIcon />}
            color="#00897b"
          />
        </Grid>

        {/* ✅ LIVE NODES CARD */}
        <Grid item xs={12} md={3}>
          <StatCard
            title="Live Nodes"
            value={liveCount}
            icon={<FlashOnIcon />}
            color="#673ab7"
            onClick={() => navigate("/live-nodes")}
          />
        </Grid>
      </Grid>
    </div>
  );
}
