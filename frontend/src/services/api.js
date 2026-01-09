// src/services/api.js
import axios from "axios";

const API_BASE = import.meta.env.VITE_API_BASE || "https://backend-nware.onrender.com";

const api = axios.create({
  baseURL: API_BASE,
  timeout: 10000,
});

/* ---------------------- MASTERDATA ---------------------- */
export async function getMasterdata(nodeId = null, limit = 200) {
  try {
    const params = {};
    if (nodeId) params.nodeId = nodeId;
    if (limit) params.limit = limit;

    const res = await api.get("/api/masterdata", { params });
    return res.data;
  } catch (e) {
    console.error("getMasterdata error:", e);
    return [];
  }
}

/* ---------------------- ALERTS ---------------------- */
export async function getAlerts(limit = 100) {
  try {
    const res = await api.get("/api/alerts", { params: { limit } });
    return res.data;
  } catch (e) {
    console.error("getAlerts error:", e);
    return [];
  }
}

export async function postAlert(payload) {
  try {
    const res = await api.post("/api/alerts", payload);
    return res.data;
  } catch (e) {
    console.error("postAlert error:", e);
    return {};
  }
}

/* ---------------------- PREDICTIONS ---------------------- */
export async function getPredictionsLatest(limit = 200) {
  try {
    const res = await api.get("/api/predictions/latest", { params: { limit } });
    return res.data;
  } catch (e) {
    console.error("getPredictionsLatest error:", e);
    return [];
  }
}

/* ---------------------- REPORTS ---------------------- */
export async function postReportGenerate(body = {}) {
  try {
    const res = await api.post("/api/reports/generate", body);
    return res.data;
  } catch (e) {
    console.error("postReportGenerate error:", e);
    return {};
  }
}

export async function getReports(limit = 200) {
  try {
    const res = await api.get("/api/reports", { params: { limit } });
    return res.data;
  } catch (e) {
    console.error("getReports error:", e);
    return [];
  }
}

/* ---------------------- NODE HEALTH ---------------------- */
export async function getNodeHealth() {
  try {
    const res = await api.get("/api/nodehealth");
    return res.data;
  } catch (e) {
    console.error("getNodeHealth error:", e);
    return [];
  }
}

/* ---------------------- LIVE NODES ---------------------- */
export async function getLiveNodes(windowSec = 15) {
  try {
    const res = await api.get("/api/live-nodes", { params: { window: windowSec } });
    return res.data;
  } catch (e) {
    console.error("getLiveNodes error:", e);
    return { nodes: [], count: 0 };
  }
}

export default api;
