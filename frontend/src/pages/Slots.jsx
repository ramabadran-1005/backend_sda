
import React, { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { getMasterdata, getPredictionsLatest } from '../services/api';
import queryString from 'query-string';
import { GaugeSmall } from './_miniGauges';

export default function Slots() {
  const nav = useNavigate();
  const loc = useLocation();
  const qs = queryString.parse(loc.search);
  const filterWarehouse = qs.warehouse;
  const [slots, setSlots] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => { load(); }, [loc.search]);

  async function load() {
    setLoading(true);
    let rows = await getPredictionsLatest();
    if (!rows || rows.length === 0) rows = await getMasterdata();

    const map = {};
    rows.forEach(r => {
      const id = (r.nodeId || r.NodeID || '') + '';
      if (!/^\d{4,}$/.test(id)) return;
      const w = parseInt(id.substring(0,1),10);
      const s = parseInt(id.substring(1,3),10);
      if (filterWarehouse && Number(filterWarehouse) !== w) return;
      map[w] = map[w] || {};
      map[w][s] = map[w][s] || [];
      const score = Number(r.riskScore || r.risk || 0);
      map[w][s].push({ id, score, row: r });
    });

    const out = [];
    Object.keys(map).forEach(w => {
      Object.keys(map[w]).forEach(s => {
        const arr = map[w][s];
        const avg = arr.length ? arr.reduce((a,b)=>a+(b.score||0),0)/arr.length : 0;
        out.push({ warehouse: Number(w), slot: Number(s), avg, count: arr.length });
      });
    });
    out.sort((a,b) => a.warehouse - b.warehouse || a.slot - b.slot);
    setSlots(out);
    setLoading(false);
  }

  if (loading) return <div style={{padding:16}}>Loading slots...</div>;
  if (!slots.length) return <div style={{padding:16}}>No slots</div>;

  return (
    <div style={{padding:16}}>
      <div style={{display:'grid', gridTemplateColumns:'1fr', gap:12}}>
        {slots.map(s => (
          <div key={`${s.warehouse}-${s.slot}`} style={{display:'flex', alignItems:'center', background:'#fff', padding:12, borderRadius:8, boxShadow:'0 2px 6px rgba(0,0,0,0.05)'}}>
            <div style={{width:80}}><GaugeSmall value={s.avg} size={64}/></div>
            <div style={{flex:1, marginLeft:12}}>
              <div style={{fontWeight:700}}>Warehouse {s.warehouse} • Slot {s.slot}</div>
              <div style={{color:'#666'}}>{s.count} nodes • Avg {s.avg.toFixed(1)}%</div>
            </div>
            <div>
              <button onClick={() => nav(`/nodes?warehouse=${s.warehouse}&slot=${s.slot}`)} style={{background:'#FFC107', border:'none', padding:'8px 12px', borderRadius:6, cursor:'pointer'}}>Open</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

