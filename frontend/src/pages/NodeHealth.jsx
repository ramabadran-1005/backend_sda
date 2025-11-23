import React, { useEffect, useState } from "react";
import List from "@mui/material/List";
import ListItem from "@mui/material/ListItem";
import ListItemText from "@mui/material/ListItemText";
import { getNodeHealth, getMasterdata } from "../services/api";

export default function NodeHealth() {
  const [rows, setRows] = useState([]);
  useEffect(() => {
    (async () => {
      let r = await getNodeHealth();
      if (!r || r.length === 0) r = await getMasterdata();
      setRows(r);
    })();
  }, []);
  return (
    <div style={{ padding: 24 }}>
      <List>
        {rows.map((n, idx) => (
          <ListItem key={idx}>
            <ListItemText primary={`Node ${n.NodeID ?? n.nodeId ?? n._id ?? "NA"}`} secondary={`Readings: ${n.readingCount ?? 0} • Uptime: ${n.uptimeSec ?? n.Uptime_sec ?? 0}s`} />
          </ListItem>
        ))}
      </List>
    </div>
  );
}
