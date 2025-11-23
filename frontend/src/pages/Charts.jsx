import React, { useEffect, useState } from 'react';
import { getMasterdata } from '../services/api';
import { LineChart, Line, CartesianGrid, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer } from 'recharts';

export default function Charts() {
  const [data, setData] = useState([]);
  const [node, setNode] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(()=>{ load(); }, []);

  async function load() {
    setLoading(true);
    const md = await getMasterdata();
    // for demo: pick first node and build time-series using last 100 rows
    if (md && md.length) {
      const byNode = {};
      md.forEach((r, idx) => {
        const id = (r.NodeID || r.nodeId || '') + '';
        if (!id) return;
        byNode[id] = byNode[id] || [];
        byNode[id].push({ idx, TGS2620: Number(r.TGS2620 || r.tgs2620 || 0), TGS2602: Number(r.TGS2602 || r.tgs2602 || 0), TGS2600: Number(r.TGS2600 || r.tgs2600 || 0), timestamp: r.Timestamp || r.timestamp || r.createdAt || '' });
      });
      const first = Object.keys(byNode)[0];
      setNode(first || '');
      setData(byNode[first] || []);
    }
    setLoading(false);
  }

  if (loading) return <div style={{padding:16}}>Loading charts...</div>;
  if (!data.length) return <div style={{padding:16}}>No timeseries data</div>;

  return (
    <div style={{padding:16}}>
      <h3>Node timeseries — {node}</h3>
      <div style={{height:360}}>
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data}>
            <CartesianGrid stroke="#eee" />
            <XAxis dataKey="idx" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="TGS2620" stroke="#ff4d4f" dot={false} />
            <Line type="monotone" dataKey="TGS2602" stroke="#52c41a" dot={false} />
            <Line type="monotone" dataKey="TGS2600" stroke="#1890ff" dot={false} />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
