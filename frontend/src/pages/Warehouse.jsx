
import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { getPredictionsLatest, getMasterdata } from '../services/api';
import { GaugeSmall } from './_miniGauges';

export default function Warehouse() {
  const [warehouses, setWarehouses] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => { load(); }, []);

  async function load() {
    setLoading(true);
    let preds = await getPredictionsLatest();
    if (!preds || preds.length === 0) {
      const md = await getMasterdata();
      // compute one row per node (latest)
      const latest = {};
      md.forEach((r) => {
        const idRaw = (r.NodeID || r.nodeId || '') + '';
        if (!idRaw) return;
        const ts = r.Timestamp || r.timestamp || r.createdAt || '';
        if (!latest[idRaw] || (ts && new Date(ts) > new Date(latest[idRaw].Timestamp || latest[idRaw].timestamp || 0))) {
          latest[idRaw] = r;
        }
      });
      preds = Object.entries(latest).map(([k,v]) => ({ nodeId: k, tgs2620: v.TGS2620 || v.tgs2620, tgs2602: v.TGS2602 || v.tgs2602, tgs2600: v.TGS2600 || v.tgs2600 }));
    }

    // parse numeric node id format: first digit = wh, next two digits = slot, rest = node
    const whmap = {};
    preds.forEach((p) => {
      const id = (p.nodeId || p.NodeID || '') + '';
      if (!/^\d{4,}$/.test(id)) return; // ignore too-short ids (<4 digits) as you requested
      const w = parseInt(id.substring(0,1), 10);
      const slot = parseInt(id.substring(1,3), 10);
      whmap[w] = whmap[w] || { nodes: [], avg: 0 };
      const score = (p.riskScore !== undefined) ? Number(p.riskScore) : 0;
      whmap[w].nodes.push({ id, score });
    });

    const list = Object.keys(whmap).map(k => {
      const arr = whmap[k].nodes;
      const avg = arr.length ? (arr.reduce((s, n) => s + (n.score || 0), 0) / arr.length) : 0;
      return { warehouse: Number(k), avg, count: arr.length };
    }).sort((a,b) => a.warehouse - b.warehouse);

    setWarehouses(list);
    setLoading(false);
  }

  if (loading) return <div style={{padding:20}}>Loading...</div>;
  if (!warehouses.length) return <div style={{padding:20}}>No warehouses found</div>;

  return (
    <div style={{display:'grid', gridTemplateColumns:'repeat(auto-fill, minmax(220px, 1fr))', gap:16, padding:16}}>
      {warehouses.map(w => (
        <div key={w.warehouse} style={{background:'#fff', borderRadius:8, padding:12, boxShadow:'0 2px 6px rgba(0,0,0,0.06)', textAlign:'center', cursor:'pointer'}} onClick={() => navigate(`/slots?warehouse=${w.warehouse}`)}>
          <div style={{display:'flex', justifyContent:'center', alignItems:'center', marginBottom:8}}>
            <GaugeSmall value={w.avg} size={96}/>
          </div>
          <div style={{fontWeight:700}}>Warehouse {w.warehouse}</div>
          <div style={{color:'#666', marginTop:6}}>{w.count} nodes</div>
        </div>
      ))}
    </div>
  );
}

