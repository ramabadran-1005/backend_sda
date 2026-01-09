co`Anst API = import.meta.env.VITE_API_BASE;

// MASTERDATA
export async function getMasterdata() {
  const res = await fetch(`${API}/api/masterdata`);
  return res.json();
}

// ALERTS (read)
export async function getAlerts() {
  const res = await fetch(`${API}/api/alerts`);
  return res.json();
}

// ALERTS (write)
export async function postAlert(alert) {
  const res = await fetch(`${API}/api/alerts`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(alert),
  });
  return res.json();
}

// PREDICTIONS (latest)
export async function getPredictionsLatest() {
  const res = await fetch(`${API}/api/predictions/latest`);
  return res.json();
}

// REPORTS (read)
export async function getReports() {
  const res = await fetch(`${API}/api/reports`);
  return res.json();
}

// REPORTS (generate)
export async function postReportGenerate(report) {
  const res = await fetch(`${API}/api/reports/generate`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(report),
  });
  return res.json();
}

``
