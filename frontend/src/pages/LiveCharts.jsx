import React, { useEffect, useState } from "react";
import { LineChart, Line, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer } from "recharts";
import { getMasterdata } from "../services/api";

export default function LiveCharts() {
  const [data, setData] = useState([]);

  async function load() {
    const rows = await getMasterdata();
    if (!rows) return;

    // use only latest 40 readings (for smooth animation)
    const trimmed = rows.slice(-40).map(r => ({
      Timestamp: r.Timestamp,
      TGS2620: Number(r.TGS2620),
      TGS2602: Number(r.TGS2602),
      TGS2600: Number(r.TGS2600),
      CPU: Number(r.CPU_Temp_C),
      RSSI: Number(r.RSSI_dBm),
      Heap: Number(r.FreeHeap_bytes)
    }));

    setData(trimmed);
  }

  useEffect(() => {
    load();
    const interval = setInterval(load, 3000);
    return () => clearInterval(interval);
  }, []);

  const ChartBlock = ({ title, dataKey }) => (
    <div style={{ background: "#fff", padding: 16, borderRadius: 10, marginBottom: 24 }}>
      <h3>{title}</h3>
      <div style={{ width: "100%", height: 300 }}>
        <ResponsiveContainer>
          <LineChart data={data}>
            <XAxis dataKey="Timestamp" hide />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey={dataKey} stroke="#1976d2" strokeWidth={2} dot={false} />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );

  return (
    <div style={{ padding: 24 }}>
      <h2>📈 Live Sensor Charts</h2>
      <ChartBlock title="TGS2620" dataKey="TGS2620" />
      <ChartBlock title="TGS2602" dataKey="TGS2602" />
      <ChartBlock title="TGS2600" dataKey="TGS2600" />
      <ChartBlock title="CPU Temperature (°C)" dataKey="CPU" />
      <ChartBlock title="WiFi RSSI (dBm)" dataKey="RSSI" />
      <ChartBlock title="ESP32 Free Heap (bytes)" dataKey="Heap" />
    </div>
  );
}
