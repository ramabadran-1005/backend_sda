import React, { useEffect, useState } from "react";
import Grid from "@mui/material/Grid";
import Paper from "@mui/material/Paper";
import Typography from "@mui/material/Typography";
import SensorsIcon from "@mui/icons-material/Sensors";
import WarningIcon from "@mui/icons-material/Warning";
import AssessmentIcon from "@mui/icons-material/Assessment";
import ArticleIcon from "@mui/icons-material/Article";
import { getNodeHealth, getAlerts, getPredictionsLatest, getReports } from "../services/api";

function StatCard({ title, value, icon, color }) {
  return (
    <Paper sx={{ p: 2, display: "flex", flexDirection: "column", alignItems: "center", gap: 1 }}>
      <div style={{ fontSize: 34, color }}>{icon}</div>
      <Typography variant="h5" sx={{ fontWeight: 700 }}>{value}</Typography>
      <Typography variant="body2" color="text.secondary">{title}</Typography>
    </Paper>
  );
}

export default function Overview() {
  const [loading, setLoading] = useState(true);
  const [nodes, setNodes] = useState([]);
  const [alerts, setAlerts] = useState([]);
  const [preds, setPreds] = useState([]);
  const [reps, setReps] = useState([]);

  useEffect(() => {
    (async () => {
      const [nh, al, pr, rp] = await Promise.all([getNodeHealth(), getAlerts(), getPredictionsLatest(), getReports()]);
      setNodes(nh);
      setAlerts(al);
      setPreds(pr);
      setReps(rp);
      setLoading(false);
    })();
  }, []);

  if (loading) return <div style={{ padding: 24 }}>Loading...</div>;

  return (
    <div style={{ padding: 24 }}>
      <Grid container spacing={2}>
        <Grid item xs={12} md={3}><StatCard title="Nodes" value={nodes.length} icon={<SensorsIcon />} color="#184d19" /></Grid>
        <Grid item xs={12} md={3}><StatCard title="Alerts" value={alerts.length} icon={<WarningIcon />} color="#d32f2f" /></Grid>
        <Grid item xs={12} md={3}><StatCard title="Predictions" value={preds.length} icon={<AssessmentIcon />} color="#ff9800" /></Grid>
        <Grid item xs={12} md={3}><StatCard title="Reports" value={reps.length} icon={<ArticleIcon />} color="#00897b" /></Grid>
      </Grid>
    </div>
  );
}
