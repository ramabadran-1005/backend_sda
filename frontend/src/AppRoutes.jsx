import React from "react";
import { Routes, Route, Navigate } from "react-router-dom";

import Overview from "./pages/Overview";
import Warehouse from "./pages/Warehouse";
import Slots from "./pages/Slots";
import Nodes from "./pages/Nodes";
import NodeHealth from "./pages/NodeHealth";
import Predictions from "./pages/Predictions";
import Alerts from "./pages/Alerts";
import Reports from "./pages/Reports";
import Charts from "./pages/Charts";

export default function AppRoutes() {
  return (
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
  );
}
