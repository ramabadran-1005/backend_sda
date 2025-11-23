
import React, { useEffect, useState } from "react";
import List from "@mui/material/List";
import ListItem from "@mui/material/ListItem";
import ListItemText from "@mui/material/ListItemText";
import IconButton from "@mui/material/IconButton";
import RefreshIcon from "@mui/icons-material/Refresh";
import { getPredictionsLatest } from "../services/api";

export default function Predictions() {
  const [preds, setPreds] = useState([]);
  useEffect(() => { load(); }, []);
  async function load() {
    const p = await getPredictionsLatest();
    setPreds(p);
  }
  async function refreshOne(p) {
    try {
      await postPrediction({ sequence: [[p.tgs2620 ?? p.TGS2620 ?? 0, p.tgs2602 ?? p.TGS2602 ?? 0, p.tgs2600 ?? p.TGS2600 ?? 0]], nodeId: p.nodeId ?? p.NodeID });
      await load();
    } catch (e) { console.error(e); }
  }
  return (
    <div style={{ padding: 24 }}>
      <List>
        {preds.map((p, i) => (
          <ListItem key={i} secondaryAction={<IconButton onClick={() => refreshOne(p)}><RefreshIcon /></IconButton>}>
            <ListItemText primary={`Node ${p.nodeId ?? p.NodeID ?? "NA"}`} secondary={`Risk ${(Number(p.riskScore ?? p.risk ?? 0)).toFixed(1)}% • ${p.status ?? ""}`} />
          </ListItem>
        ))}
      </List>
    </div>
  );
}
