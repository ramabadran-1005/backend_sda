import React from "react";
import { useNavigate, useLocation } from "react-router-dom";
import List from "@mui/material/List";
import ListItem from "@mui/material/ListItem";
import ListItemButton from "@mui/material/ListItemButton";
import ListItemIcon from "@mui/material/ListItemIcon";
import ListItemText from "@mui/material/ListItemText";
import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import Divider from "@mui/material/Divider";
import DashboardIcon from "@mui/icons-material/Dashboard";
import WidgetsIcon from "@mui/icons-material/Widgets";
import StorageIcon from "@mui/icons-material/Storage";
import DeviceHubIcon from "@mui/icons-material/DeviceHub";
import HealthAndSafetyIcon from "@mui/icons-material/HealthAndSafety";
import AnalyticsIcon from "@mui/icons-material/Analytics";
import ReportProblemIcon from "@mui/icons-material/ReportProblem";
import ArticleIcon from "@mui/icons-material/Article";
import ShowChartIcon from "@mui/icons-material/ShowChart";

const MENU = [
  { key: "overview", label: "Overview", icon: <DashboardIcon /> },
  { key: "warehouse", label: "Warehouse", icon: <WidgetsIcon /> },
  { key: "slots", label: "Slots", icon: <StorageIcon /> },
  { key: "nodes", label: "Nodes", icon: <DeviceHubIcon /> },
  { key: "nodehealth", label: "Node Health", icon: <HealthAndSafetyIcon /> },
  { key: "predictions", label: "Predictions", icon: <AnalyticsIcon /> },
  { key: "alerts", label: "Alerts", icon: <ReportProblemIcon /> },
  { key: "reports", label: "Reports", icon: <ArticleIcon /> },
  { key: "charts", label: "Charts", icon: <ShowChartIcon /> },
];

// Use the uploaded screenshot path. Dev system will transform this to a URL.
const LOGO_URL = "/mnt/data/Screenshot 2025-11-21 at 11.45.01.png";

export default function Sidebar() {
  const navigate = useNavigate();
  const location = useLocation();
  const current = location.pathname.replace("/", "") || "overview";

  return (
    <Box sx={{ width: 260, bgcolor: "#123b20", color: "#fff", display: "flex", flexDirection: "column", minHeight: "100vh" }}>
      <Box sx={{ p: 3, display: "flex", alignItems: "center", gap: 2 }}>
        <Box sx={{ width: 56, height: 56, borderRadius: 2, overflow: "hidden", bgcolor: "#fff" }}>
          <img src={LOGO_URL} alt="logo" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
        </Box>
        <Box>
          <Typography variant="h6" sx={{ color: "#ffc107", fontWeight: 700 }}>NWarehouse</Typography>
          <Typography variant="caption" sx={{ color: "#d0ffd8" }}>Manager Dashboard</Typography>
        </Box>
      </Box>
      <Divider sx={{ borderColor: "rgba(255,255,255,0.08)" }} />
      <List sx={{ flex: 1 }}>
        {MENU.map((m) => {
          const active = m.key === current;
          return (
            <ListItem key={m.key} disablePadding>
              <ListItemButton onClick={() => navigate(`/${m.key}`)} selected={active} sx={{ color: active ? "#000" : "#fff", bgcolor: active ? "#ffc107" : "transparent", mx: 1, borderRadius: 1 }}>
                <ListItemIcon sx={{ color: active ? "#000" : "#fff" }}>{m.icon}</ListItemIcon>
                <ListItemText primary={m.label} />
              </ListItemButton>
            </ListItem>
          );
        })}
      </List>
      <Divider sx={{ borderColor: "rgba(255,255,255,0.08)" }} />
      <Box sx={{ p: 2 }}>
        <Typography variant="body2" sx={{ color: "rgba(255,255,255,0.7)" }}>Signed in as <strong>Admin</strong></Typography>
      </Box>
    </Box>
  );
}
