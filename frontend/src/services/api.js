import axios from "axios";

const API = axios.create({
  baseURL: "https://backend-sda-5.onrender.com",
  timeout: 15000,
});

const safe = (p) => (p && p.data ? p.data : []);

// -------------------------
// GET endpoints
// -------------------------

export async function getMasterdata() {
  try {
    const r = await API.get("/api/masterdata");
    return safe(r);
  } catch (e) {
    console.error("getMasterdata error:", e);
    return [];
  }
}

export async function getPredictionsLatest() {
  try {
    const r = await API.get("/api/predictions/latest");
    return safe(r);
  } catch (e) {
    console.error("getPredictionsLatest error:", e);
    return [];
  }
}

export async function getPredictions() {
  try {
    const r = await API.get("/api/predictions");
    return safe(r);
  } catch (e) {
    console.error("getPredictions error:", e);
    return [];
  }
}

export async function getAlerts() {
  try {
    const r = await API.get("/api/alerts");
    return safe(r);
  } catch (e) {
    console.error("getAlerts error:", e);
    return [];
  }
}

export async function getReports() {
  try {
    const r = await API.get("/api/reports");
    return safe(r);
  } catch (e) {
    console.error("getReports error:", e);
    return [];
  }
}

// -------------------------
// AUTH endpoints
// -------------------------

export async function registerUser(payload) {
  try {
    const r = await API.post("/api/auth/register", payload);
    return r.data;
  } catch (e) {
    console.error("registerUser error:", e);
    throw e;
  }
}

export async function loginUser(payload) {
  try {
    const r = await API.post("/api/auth/login", payload);
    return r.data;
  } catch (e) {
    console.error("loginUser error:", e);
    throw e;
  }
}

// -------------------------
// POST endpoints
// -------------------------

export async function postAlert(payload) {
  try {
    const r = await API.post("/api/alerts", payload);
    return r.data;
  } catch (e) {
    console.error("postAlert error:", e);
    throw e;
  }
}

export async function postReportGenerate(payload) {
  try {
    const r = await API.post("/api/reports/generate", payload);
    return r.data;
  } catch (e) {
    console.error("postReportGenerate error:", e);
    throw e;
  }
}

export default API;
