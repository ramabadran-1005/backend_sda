import React, { useEffect, useState } from "react";
import List from "@mui/material/List";
import ListItem from "@mui/material/ListItem";
import ListItemText from "@mui/material/ListItemText";
import TextField from "@mui/material/TextField";
import Button from "@mui/material/Button";
import { getAlerts, postAlert, getMasterdata } from "../services/api";

export default function Alerts() {
  const [alerts, setAlerts] = useState([]);
  const [node, setNode] = useState("");
  const [sensor, setSensor] = useState("");

  useEffect(() => { (async ()=> { let a = await getAlerts(); if (!a || a.length===0){ const m = await getMasterdata(); if (m.length) await postAlert({nodeId: m[0].NodeID ?? m[0].nodeId ?? 2101, sensorType: "TGS2620", message: "sample", timestamp: new Date().toISOString()}); a = await getAlerts(); } setAlerts(a); })(); }, []);

  async function create() {
    await postAlert({ nodeId: node || "unknown", sensorType: sensor || "unknown", timestamp: new Date().toISOString() });
    setNode(""); setSensor("");
    setAlerts(await getAlerts());
  }

  return (
    <div style={{ padding: 24 }}>
      <div style={{ display: "flex", gap: 8, marginBottom: 12 }}>
        <TextField label="NodeId" value={node} onChange={(e)=>setNode(e.target.value)} />
        <TextField label="Sensor" value={sensor} onChange={(e)=>setSensor(e.target.value)} />
        <Button variant="contained" onClick={create}>Create</Button>
      </div>

      <List>
        {alerts.map((a, i) => (
          <ListItem key={i}>
            <ListItemText primary={`${a.sensorType ?? a.sensor} • Node ${a.nodeId ?? a.NodeID ?? "NA"}`} secondary={a.timestamp ?? a.createdAt} />
          </ListItem>
        ))}
      </List>
    </div>
  );
}
