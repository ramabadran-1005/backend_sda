import React from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import CssBaseline from "@mui/material/CssBaseline";
import Box from "@mui/material/Box";
import Sidebar from "./layout/Sidebar";
import Overview from "./pages/Overview";
import Warehouse from "./pages/Warehouse";
import Slots from "./pages/Slots";
import Nodes from "./pages/Nodes";
import NodeHealth from "./pages/NodeHealth";
import Predictions from "./pages/Predictions";
import Alerts from "./pages/Alerts";
import Reports from "./pages/Reports";
import Charts from "./pages/Charts";

export default function App() {
  return (
    <>
      <CssBaseline />
      <Box sx={{ display: "flex", minHeight: "100vh" }}>
        <Sidebar />
        <Box component="main" sx={{ flex: 1, bgcolor: "#f8f8f8", padding: 2 }}>
          <Routes>
            <Route path="/" element={<Navigate to="/overview" replace />} />
            <Route path="/overview" element={<Overview />} />
            <Route path="/warehouse" element={<Warehouse />} />
            <Route path="/slots" element={<Slots />} />
            <Route path="/nodes" element={<Nodes />} />
            <Route path="/nodehealth" element={<NodeHealth />} />
            <Route path="/predictions" element={<Predictions />} />
            <Route path="/alerts" element={<Alerts />} />
            <Route path="/reports" element={<Reports />} />
            <Route path="/charts" element={<Charts />} />
          </Routes>
        </Box>
      </Box>
    </>
  );
}
rm src/App.css
rm src/index.css
rm src/assets/react.svg

