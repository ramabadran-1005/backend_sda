// src/pages/Dashboard.jsx
import React, { useEffect, useState, useRef } from "react";
import { getMasterdata, getLatestPredictions, getAlerts, getNodeHealth } from "../services/api";

function NodeRow({ r, pred }) {
  return (
    <tr>
      <td>{r.NodeID ?? r.nodeId}</td>
      <td>{r.TGS2620}</td>
      <td>{r.TGS2602}</td>
      <td>{r.TGS2600}</td>
      <td>{r.RSSI_dBm}</td>
      <td>{r.CPU_Temp_C}</td>
      <td>{r.Uptime_sec}</td>
      <td>{new Date(r.Timestamp || r.receivedAt || Date.now()).toLocaleString()}</td>
      <td>{pred ? `${pred.riskScore} (${pred.health_state})` : "-"}</td>
    </tr>
  );
}

export default function Dashboard() {
  const [rows, setRows] = useState([]);
  const [preds, setPreds] = useState({});
  const [alerts, setAlerts] = useState([]);
  const [nodehealth, setNodehealth] = useState([]);
  const polling = useRef(null);

  async function fetchAll() {
    try {
      const [m, p, a, nh] = await Promise.all([
        getMasterdata(),          // latest masterdata entries (limit applied by backend)
        getLatestPredictions(),   // predictions
        getAlerts(50),
        getNodeHealth()
      ]);
      setRows(m || []);
      // convert predictions into map by nodeId
      const pMap = {};
      (p || []).forEach(pp => {
        const key = pp.nodeId ?? pp.nodeID ?? pp.node;
        pMap[String(key)] = pp;
      });
      setPreds(pMap);
      setAlerts(a || []);
      setNodehealth(nh || []);
    } catch (err) {
      console.error("fetchAll error", err);
    }
  }

  useEffect(() => {
    fetchAll();
    polling.current = setInterval(fetchAll, 5000); // 5s
    return () => clearInterval(polling.current);
  }, []);

  return (
    <div style={{ padding: 20 }}>
      <h2>NWarehouse — Live Dashboard</h2>

      <section style={{ marginBottom: 12 }}>
        <strong>Alerts:</strong>
        <ul>
          {alerts.slice(0,5).map((al, i) => (
            <li key={i}>{al.nodeId ?? al.NodeID ?? "unknown"} — {al.message ?? JSON.stringify(al)}</li>
          ))}
        </ul>
      </section>

      <section style={{ marginBottom: 12 }}>
        <strong>Node Health Summary:</strong>
        <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
          {nodehealth.map((n, idx) => (
            <div key={idx} style={{ padding: 8, border: "1px solid #ddd", borderRadius: 6, minWidth: 160 }}>
              <div><strong>Node:</strong> {n.NodeID}</div>
              <div><strong>Readings:</strong> {n.readingCount}</div>
              <div><strong>Uptime sec:</strong> {n.uptimeSec}</div>
            </div>
          ))}
        </div>
      </section>

      <section>
        <table style={{ width: "100%", borderCollapse: "collapse" }}>
          <thead>
            <tr style={{ textAlign: "left", borderBottom: "1px solid #ddd" }}>
              <th>NodeID</th><th>TGS2620</th><th>TGS2602</th><th>TGS2600</th><th>RSSI</th><th>CPU C</th><th>Uptime</th><th>Timestamp</th><th>Prediction</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((r, i) => <NodeRow key={i} r={r} pred={preds[String(r.NodeID ?? r.nodeId ?? "unknown")]} />)}
          </tbody>
        </table>
      </section>
    </div>
  );
}
