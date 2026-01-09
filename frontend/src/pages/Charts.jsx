import React, { useEffect, useState } from "react";
import { getMasterdata } from "../services/api";
import {
  LineChart, Line, CartesianGrid, XAxis, YAxis,
  Tooltip, Legend, ResponsiveContainer
} from "recharts";

export default function Charts() {
  const [data, setData] = useState([]);
  const [node, setNode] = useState("");
  const [allNodes, setAllNodes] = useState([]);

  async function load() {
    const md = await getMasterdata();

    if (!md || !md.length) return;

    const grouped = {};

    md.forEach((r, idx) => {
      const id = String(r.NodeID || r.nodeId || "");
      if (!id) return;

      if (!grouped[id]) grouped[id] = [];
      grouped[id].push({
        idx,
        TGS2620: Number(r.TGS2620 || 0),
        TGS2602: Number(r.TGS2602 || 0),
        TGS2600: Number(r.TGS2600 || 0),
        Timestamp: r.Timestamp || ""
      });
    });

    const nodes = Object.keys(grouped);

    setAllNodes(nodes);

    if (!node && nodes.length > 0) {
      setNode(nodes[0]);
      setData(grouped[nodes[0]]);
    } else if (node && grouped[node]) {
      setData(grouped[node]);
    }
  }

  useEffect(() => {
    load();
    const t = setInterval(load, 3000);
    return () => clearInterval(t);
  }, [node]);

  return (
    <div style={{ padding: 16 }}>
      <h3>Charts</h3>

      <select
        style={{ padding: 8, marginBottom: 20 }}
        value={node}
        onChange={(e) => setNode(e.target.value)}
      >
        <option value="">Select Node</option>
        {allNodes.map((n) => (
          <option key={n} value={n}>
            Node {n}
          </option>
        ))}
      </select>

      <div style={{ height: 360 }}>
        {data.length === 0 ? (
          <div>No data available</div>
        ) : (
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={data}>
              <CartesianGrid stroke="#ccc" />
              <XAxis dataKey="idx" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="TGS2620" stroke="#ff4d4f" dot={false} />
              <Line type="monotone" dataKey="TGS2602" stroke="#52c41a" dot={false} />
              <Line type="monotone" dataKey="TGS2600" stroke="#1890ff" dot={false} />
            </LineChart>
          </ResponsiveContainer>
        )}
      </div>
    </div>
  );
}
