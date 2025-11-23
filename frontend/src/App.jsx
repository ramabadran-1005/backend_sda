import React from "react";
import Sidebar from "./layout/Sidebar";
import AppRoutes from "./AppRoutes";
import Box from "@mui/material/Box";

export default function App() {
  return (
    <Box sx={{ display: "flex", minHeight: "100vh" }}>
      <Sidebar />
      <Box component="main" sx={{ flex: 1, bgcolor: "#f8f8f8" }}>
        <AppRoutes />
      </Box>
    </Box>
  );
}
