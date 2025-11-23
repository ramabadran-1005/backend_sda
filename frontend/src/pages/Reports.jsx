import React, { useEffect, useState } from "react";
import {
  getMasterdata,
  postReportGenerate,
  getReports,
} from "../services/api";
import { saveAs } from "file-saver";
import Papa from "papaparse";
import jsPDF from "jspdf";

export default function Reports() {
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [type, setType] = useState("");
  const [options, setOptions] = useState([]);
  const [selected, setSelected] = useState("");
  const [popupOpen, setPopupOpen] = useState(false);
  const [reports, setReports] = useState([]);

  useEffect(() => {
    loadReports();
  }, []);

  async function loadReports() {
    const r = await getReports();
    setReports(r || []);
  }

  async function openSelectionPopup() {
    let data = await getMasterdata();

    if (type === "node") {
      const ids = [...new Set(data.map((d) => d.NodeID))];
      setOptions(ids);
    } else if (type === "slot") {
      const slots = [...new Set(data.map((d) => String(d.NodeID).substring(1, 3)))];
      setOptions(slots);
    } else if (type === "warehouse") {
      const warehouses = [...new Set(data.map((d) => String(d.NodeID).substring(0, 1)))];
      setOptions(warehouses);
    }

    setPopupOpen(true);
  }

  async function generateReport() {
    if (!from || !to || !type || !selected)
      return alert("Fill all fields");

    const payload = { from, to, type, value: selected };
    await postReportGenerate(payload);
    alert("Report generated");
    loadReports();
  }

  function downloadCSV() {
    const csv = Papa.unparse(reports);
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    saveAs(blob, "report.csv");
  }

  function downloadPDF() {
    const doc = new jsPDF();
    doc.text("NWarehouse Report", 10, 10);

    let y = 20;
    reports.forEach((r) => {
      doc.text(JSON.stringify(r), 10, y);
      y += 10;
    });

    doc.save("report.pdf");
  }

  return (
    <div style={{ padding: 20 }}>
      <h2 style={{ marginBottom: 20 }}>Reports</h2>

      {/* Date Inputs */}
      <div style={{ display: "flex", gap: 20 }}>
        <div>
          <label>From Date</label><br />
          <input type="date" value={from} onChange={(e) => setFrom(e.target.value)} />
        </div>

        <div>
          <label>To Date</label><br />
          <input type="date" value={to} onChange={(e) => setTo(e.target.value)} />
        </div>
      </div>

      {/* Report Type */}
      <div style={{ marginTop: 20 }}>
        <label>Select Report Type</label><br />
        <select value={type} onChange={(e) => setType(e.target.value)}>
          <option value="">-- Select --</option>
          <option value="node">Node-wise</option>
          <option value="slot">Slot-wise</option>
          <option value="warehouse">Warehouse-wise</option>
        </select>
      </div>

      {/* Select ID */}
      <button
        style={{ marginTop: 20, padding: "8px 16px" }}
        onClick={openSelectionPopup}
        disabled={!type}
      >
        Choose {type}
      </button>

      {/* Popup */}
      {popupOpen && (
        <div
          style={{
            position: "fixed",
            inset: 0,
            background: "rgba(0,0,0,0.35)",
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
          }}
        >
          <div
            style={{
              background: "#fff",
              padding: 20,
              borderRadius: 10,
              width: 350,
            }}
          >
            <h3>Select {type}</h3>
            <ul style={{ maxHeight: 200, overflowY: "auto", padding: 0 }}>
              {options.map((o) => (
                <li
                  key={o}
                  style={{
                    listStyle: "none",
                    padding: 10,
                    marginBottom: 5,
                    background: selected === o ? "#dcdcdc" : "#f7f7f7",
                    borderRadius: 6,
                    cursor: "pointer",
                  }}
                  onClick={() => setSelected(o)}
                >
                  {o}
                </li>
              ))}
            </ul>

            <button
              onClick={() => setPopupOpen(false)}
              style={{
                marginTop: 10,
                padding: "8px 16px",
                background: "#2196F3",
                color: "#fff",
                border: "none",
                borderRadius: 6,
                cursor: "pointer",
              }}
            >
              Done
            </button>
          </div>
        </div>
      )}

      {/* Generate Button */}
      <div style={{ marginTop: 20 }}>
        <button
          onClick={generateReport}
          disabled={!selected}
          style={{
            padding: "10px 20px",
            background: "#4CAF50",
            color: "#fff",
            borderRadius: 8,
            border: 0,
          }}
        >
          Generate Report
        </button>
      </div>

      {/* Downloads */}
      <div style={{ marginTop: 30 }}>
        <h3>Download Reports</h3>
        <button onClick={downloadCSV} style={{ marginRight: 10 }}>
          CSV
        </button>
        <button onClick={downloadPDF}>PDF</button>
      </div>

      {/* Display Generated Reports */}
      <div style={{ marginTop: 30 }}>
        <h3>Generated Reports</h3>
        <pre
          style={{
            background: "#fafafa",
            padding: 12,
            borderRadius: 8,
            maxHeight: 300,
            overflowY: "auto",
          }}
        >
          {JSON.stringify(reports, null, 2)}
        </pre>
      </div>
    </div>
  );
}
