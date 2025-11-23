import axios from "axios";

const API_BASE = "http://10.100.75.165:4000";

const api = axios.create({
  baseURL: API_BASE,
  timeout: 15000,
});

const safe = (p) => (p && p.data ? p.data : []);

// -------------------------
// GET endpoints
// -------------------------
export async function getNodeHealth() {
  try {
    const r = await api.get("/api/nodehealth");
    return safe(r);
  } catch (e) {
    console.error("getNodeHealth error:", e);
    return [];
  }
}

export async function getAlerts() {
  try {
    const r = await api.get("/api/alerts");
    return safe(r);
  } catch (e) {
    console.error("getAlerts error:", e);
    return [];
  }
}

export async function getPredictionsLatest() {
  try {
    const r = await api.get("/api/predictions/latest");
    return safe(r);
  } catch (e) {
    console.error("getPredictionsLatest error:", e);
    return [];
  }
}

export async function getReports() {
  try {
    const r = await api.get("/api/reports");
    return safe(r);
  } catch (e) {
    console.error("getReports error:", e);
    return [];
  }
}

export async function getMasterdata(query = "") {
  try {
    const r = await api.get(
      "/api/masterdata" + (query ? `?${query}` : "")
    );
    return safe(r);
  } catch (e) {
    console.error("getMasterdata error:", e);
    return [];
  }
}

// -------------------------
// POST endpoints
// -------------------------
export async function postPrediction(payload) {
  try {
    const r = await api.post("/api/predictions/predict", payload);
    return r.data;
  } catch (e) {
    console.error("postPrediction error:", e);
    throw e;
  }
}

export async function postAlert(payload) {
  try {
    const r = await api.post("/api/alerts", payload);
    return r.data;
  } catch (e) {
    console.error("postAlert error:", e);
    throw e;
  }
}

export async function postReportGenerate(payload) {
  try {
    const r = await api.post("/api/reports/generate", payload);
    return r.data;
  } catch (e) {
    console.error("postReportGenerate error:", e);
    throw e;
  }
}

export default api;
