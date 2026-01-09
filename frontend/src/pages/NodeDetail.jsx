import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { getMasterdata, getPredictionsLatest } from "../services/api.js";



export default function NodeDetail() {
  const { nodeId } = useParams();
  const [rows, setRows] = useState([]);
  const [pred, setPred] = useState(null);

  async function load() {
    const md = await getMasterdata(nodeId);
    const p = await getPredictionsLatest();

    const filteredPred = p.find(x => String(x.nodeId) === String(nodeId));

    setRows(md.filter(d => String(d.NodeID) === String(nodeId)));
    setPred(filteredPred);
  }

  useEffect(() => {
    load();
    const interval = setInterval(load, 3000);
    return () => clearInterval(interval);
  }, [nodeId]);

  if (!rows.length) return <div style={{ padding: 24 }}>Loading...</div>;

  const latest = rows[0];

  return (
    <div style={{ padding: 24 }}>
      <h2>Node {nodeId}</h2>

      {/* ------------------- RISK ------------------- */}
      <div style={{
        background: "#fff",
        padding: 20,
        borderRadius: 12,
        marginBottom: 20,
        boxShadow: "0 2px 6px rgba(0,0,0,0.15)"
      }}>
        <h3>Risk Score</h3>
        <p style={{ fontSize: 28, fontWeight: 700, color: pred?.riskScore > 50 ? "red" : "green" }}>
          {pred?.riskScore ?? "-"}%
        </p>
        <p>Status: {pred?.binary}</p>
        <p>Class: {pred?.four_class}</p>
      </div>

      {/* ------------------- SENSOR TABLE ------------------- */}
      <div style={{
        background: "#fff",
        padding: 20,
        borderRadius: 12,
        boxShadow: "0 2px 6px rgba(0,0,0,0.1)"
      }}>
        <h3>Latest Sensor Readings</h3>
        <pre style={{ fontSize: 14 }}>{JSON.stringify(latest, null, 2)}</pre>
      </div>
    </div>
  );
}
