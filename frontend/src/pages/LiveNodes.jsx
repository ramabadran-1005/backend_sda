import React, { useEffect, useState } from "react";
import { getLiveNodes } from "../services/api";

export default function LiveNodesPage() {
  const [data, setData] = useState({ nodes: [], count: 0 });
  async function load() {
    const d = await getLiveNodes(15);
    setData(d || { nodes: [], count: 0 });
  }
  useEffect(()=>{ load(); const t = setInterval(load, 3000); return ()=>clearInterval(t); }, []);
  if (!data.nodes || data.nodes.length===0) return <div style={{padding:16}}>No active nodes</div>;
  return (
    <div style={{padding:16}}>
      <h3>Live Nodes ({data.count})</h3>
      <ul>
        {data.nodes.map(n => <li key={n.nodeId}>Node {n.nodeId} — lastSeen {n.lastSeen}</li>)}
      </ul>
    </div>
  );
}
