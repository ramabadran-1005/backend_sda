
import React, { useEffect, useState } from 'react';
import { useLocation } from 'react-router-dom';
import queryString from 'query-string';
import { getMasterdata, getPredictionsLatest } from '../services/api';
import { GaugeSmall } from './_miniGauges';

export default function Nodes() {
  const loc = useLocation();
  const qs = queryString.parse(loc.search);
  const filterWarehouse = qs.warehouse;
  const filterSlot = qs.slot;

  const [nodes, setNodes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [detail, setDetail] = useState(null);

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
      if (filterSlot && Number(filterSlot) !== s) return;
      map[id] = r; // latest entry wins
    });

    const out = Object.keys(map).map(k => ({ nodeId: k, row: map[k], score: Number(map[k].riskScore || map[k].risk || 0) }));
    out.sort((a,b)=>a.nodeId.localeCompare(b.nodeId));
    setNodes(out);
    setLoading(false);
  }

  if (loading) return <div style={{padding:16}}>Loading nodes...</div>;
  if (!nodes.length) return <div style={{padding:16}}>No nodes</div>;

  return (
    <div style={{padding:16}}>
      <div style={{display:'grid', gap:12}}>
        {nodes.map(n => (
          <div key={n.nodeId} style={{display:'flex', alignItems:'center', background:'#fff', padding:12, borderRadius:8, boxShadow:'0 2px 6px rgba(0,0,0,0.05)'}}>
            <div style={{width:80}}><GaugeSmall value={n.score} size={64}/></div>
            <div style={{flex:1, marginLeft:12}}>
              <div style={{fontWeight:700}}>Node {n.nodeId}</div>
              <div style={{color:'#666'}}>Risk: {n.score.toFixed(1)}%</div>
            </div>
            <div>
              <button onClick={() => setDetail(n)} style={{background:'#FFC107', border:'none', padding:'8px 12px', borderRadius:6, cursor:'pointer'}}>Details</button>
            </div>
          </div>
        ))}
      </div>

      {detail && (
        <div style={{position:'fixed', left:0,top:0,right:0,bottom:0, background:'rgba(0,0,0,0.4)', display:'flex',alignItems:'center',justifyContent:'center'}}>
          <div style={{background:'#fff', borderRadius:8, padding:20, width:640, maxHeight:'80vh', overflowY:'auto'}}>
            <div style={{display:'flex', justifyContent:'space-between', alignItems:'center'}}>
              <h3>Node {detail.nodeId}</h3>
              <button onClick={() => setDetail(null)} style={{border:'none', background:'transparent', cursor:'pointer', fontSize:18}}>✕</button>
            </div>
            <div style={{marginTop:8}}>
              <pre style={{whiteSpace:'pre-wrap', fontSize:13}}>{JSON.stringify(detail.row, null, 2)}</pre>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

