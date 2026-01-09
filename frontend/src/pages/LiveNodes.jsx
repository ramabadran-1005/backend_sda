import React, { useEffect, useState } from "react";
import { getMasterdata } from "../services/api";

export default function LiveNodesPage() {
  const [liveNodes, setLiveNodes] = useState([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    const data = await getMasterdata();
    const now = Date.now();

    const lastSeen = {};

    data.forEach((d) => {
      const id = d.NodeID;
      const ts = new Date(d.Timestamp || d.receivedAt).getTime();
      if (!lastSeen[id]) lastSeen[id] = ts;
    });

    const active = Object.keys(lastSeen)
      .filter((id) => now - lastSeen[id] < 60000) // 60 sec = LIVE
      .map(Number);

    setLiveNodes(active);
    setLoading(false);
  }

  useEffect(() => {
    load();
    const interval = setInterval(load, 3000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ padding: 24 }}>
      <h2>Live Nodes</h2>

      {loading ? (
        <p>Loading...</p>
      ) : liveNodes.length === 0 ? (
        <p>No active nodes right now.</p>
      ) : (
        <ul>
          {liveNodes.map((id) => (
            <li
              key={id}
              style={{
                padding: 10,
                background: "#e3ffe3",
                marginBottom: 8,
                borderRadius: 6,
              }}
            >
              Node {id} — <strong>Active</strong>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
