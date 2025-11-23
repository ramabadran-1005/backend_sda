
import React from 'react';
import { CircularProgressbar, buildStyles } from 'react-circular-progressbar';
import 'react-circular-progressbar/dist/styles.css';

export function GaugeSmall({ value = 0, size = 64 }) {
  const v = Math.max(0, Math.min(100, Math.round(value)));
  const color = v > 80 ? '#e53935' : v > 50 ? '#fb8c00' : v > 20 ? '#FFC107' : '#184D19';
  return (
    <div style={{ width: size, height: size }}>
      <CircularProgressbar
        value={v}
        text={`${v}%`}
        styles={buildStyles({
          textSize: '28px',
          pathColor: color,
          textColor: color,
          trailColor: '#eee',
        })}
      />
    </div>
  );
}
export default GaugeSmall;

