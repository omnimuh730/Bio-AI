import React, { useState, useEffect } from "react";
import {
	FiActivity,
	FiZap,
	FiMoon,
	FiWind,
	FiThermometer,
	FiDroplet,
} from "react-icons/fi";

// Compact helper components
const MicroVital = ({ icon, label, value, unit, color, bg }) => (
	<div
		className="micro-vital"
		style={{ "--accent": color, "--bg-accent": bg }}
	>
		<div className="mv-icon">{icon}</div>
		<div className="mv-data">
			<div className="mv-value">
				{value}
				<span className="mv-unit">{unit}</span>
			</div>
			<div className="mv-label">{label}</div>
		</div>
	</div>
);

export default function LiveVitals() {
	const [isLive, setIsLive] = useState(true);
	const [hrData, setHrData] = useState(Array.from({ length: 40 }, () => 65));

	// Simulated Live Data
	useEffect(() => {
		if (!isLive) return;
		const interval = setInterval(() => {
			setHrData((prev) => {
				const last = prev[prev.length - 1];
				const next = Math.round(last + (Math.random() - 0.5) * 4);
				const clamped = Math.max(50, Math.min(130, next));
				return [...prev.slice(1), clamped];
			});
		}, 800);
		return () => clearInterval(interval);
	}, [isLive]);

	// SVG Path Generator for the Sparkline
	const generatePath = (data, width, height) => {
		const max = Math.max(...data, 100);
		const min = Math.min(...data, 50);
		const range = max - min;

		return data
			.map((d, i) => {
				const x = (i / (data.length - 1)) * width;
				const y = height - ((d - min) / range) * height;
				return `${i === 0 ? "M" : "L"} ${x},${y}`;
			})
			.join(" ");
	};

	const currentHR = hrData[hrData.length - 1];

	return (
		<div className="live-vitals-container">
			<div className="section-header">
				<h3>Live Vitals</h3>
				<button
					onClick={() => setIsLive(!isLive)}
					className={`live-badge ${isLive ? "pulse" : ""}`}
				>
					{isLive ? "LIVE" : "PAUSED"}
				</button>
			</div>

			{/* Main Grid: "Bento Box" Style */}
			<div className="bento-grid">
				{/* Large Block: Heart Rate Graph */}
				<div className="bento-card hr-card">
					<div className="hr-info">
						<div className="hr-label">
							<FiActivity className="icon-spin" /> Heart Rate
						</div>
						<div className="hr-big-val">
							{currentHR} <small>bpm</small>
						</div>
					</div>
					<div className="hr-chart">
						<svg viewBox="0 0 300 60" className="sparkline">
							<defs>
								<linearGradient
									id="gradHR"
									x1="0"
									y1="0"
									x2="0"
									y2="1"
								>
									<stop
										offset="0%"
										stopColor="#f43f5e"
										stopOpacity="0.4"
									/>
									<stop
										offset="100%"
										stopColor="#f43f5e"
										stopOpacity="0"
									/>
								</linearGradient>
							</defs>
							<path
								d={`${generatePath(hrData, 300, 60)} L 300,60 L 0,60 Z`}
								fill="url(#gradHR)"
							/>
							<path
								d={generatePath(hrData, 300, 60)}
								fill="none"
								stroke="#f43f5e"
								strokeWidth="2.5"
								strokeLinecap="round"
							/>
						</svg>
					</div>
				</div>

				{/* Compact Grid for other stats */}
				<div className="stats-grid">
					<MicroVital
						icon={<FiZap />}
						label="Stress"
						value="12"
						unit="%"
						color="#10b981"
						bg="#ecfdf5"
					/>
					<MicroVital
						icon={<FiWind />}
						label="SpO2"
						value="98"
						unit="%"
						color="#06b6d4"
						bg="#ecfeff"
					/>
					<MicroVital
						icon={<FiMoon />}
						label="Sleep"
						value="7.2"
						unit="h"
						color="#6366f1"
						bg="#eef2ff"
					/>
					<MicroVital
						icon={<FiDroplet />}
						label="VO2 Max"
						value="44"
						unit=""
						color="#3b82f6"
						bg="#eff6ff"
					/>
					<MicroVital
						icon={<FiThermometer />}
						label="Temp"
						value="36.6"
						unit="°C"
						color="#f59e0b"
						bg="#fffbeb"
					/>
					<MicroVital
						icon={<FiActivity />}
						label="HRV"
						value="42"
						unit="ms"
						color="#8b5cf6"
						bg="#f5f3ff"
					/>
				</div>
			</div>

			<style>{`
        .live-vitals-container {
          margin: 10px 0;
        }
        .section-header {
          display: flex; justify-content: space-between; align-items: center;
          margin-bottom: 12px; padding: 0 4px;
        }
        h3 { margin: 0; font-size: 18px; font-weight: 700; color: #1e293b; }
        
        .live-badge {
          background: #e2e8f0; color: #64748b; border: none; font-size: 10px; font-weight: 800;
          padding: 4px 10px; border-radius: 20px; letter-spacing: 0.5px; cursor: pointer;
        }
        .live-badge.pulse {
          background: #ffe4e6; color: #f43f5e;
          box-shadow: 0 0 0 0 rgba(244, 63, 94, 0.7);
          animation: badgePulse 2s infinite;
        }

        .bento-grid {
          display: flex; flex-direction: column; gap: 12px;
        }

        /* HR Card Styling */
        .bento-card {
          background: white; border-radius: 24px; padding: 16px;
          box-shadow: var(--shadow-sm); border: 1px solid rgba(255,255,255,0.8);
        }
        .hr-card {
          display: flex; justify-content: space-between; align-items: center;
          position: relative; overflow: hidden; height: 100px;
          background: linear-gradient(135deg, #fff 0%, #fff1f2 100%);
        }
        .hr-info { position: relative; z-index: 2; }
        .hr-label { display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 600; color: #f43f5e; text-transform: uppercase; margin-bottom: 4px;}
        .hr-big-val { font-size: 36px; font-weight: 800; color: #0f172a; line-height: 1; letter-spacing: -1px;}
        .hr-big-val small { font-size: 14px; font-weight: 600; color: #94a3b8; margin-left: 4px; }
        .hr-chart {
          position: absolute; right: 0; bottom: 0; width: 60%; height: 70%;
          mask-image: linear-gradient(to right, transparent, black 20%);
        }
        .sparkline { width: 100%; height: 100%; display: block; }
        .icon-spin { animation: spin 2s linear infinite; }

        /* Compact Grid Styling */
        .stats-grid {
          display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px;
        }
        .micro-vital {
          background: white; border-radius: 18px; padding: 12px 10px;
          display: flex; flex-direction: column; align-items: center; text-align: center;
          gap: 8px;
          box-shadow: var(--shadow-sm);
          transition: transform 0.2s;
        }
        .micro-vital:active { transform: scale(0.97); }
        
        .mv-icon {
          width: 28px; height: 28px; border-radius: 10px;
          background: var(--bg-accent); color: var(--accent);
          display: flex; align-items: center; justify-content: center;
          font-size: 14px;
        }
        .mv-value { font-size: 15px; font-weight: 700; color: #1e293b; }
        .mv-unit { font-size: 10px; color: #94a3b8; font-weight: 600; margin-left: 1px;}
        .mv-label { font-size: 10px; font-weight: 600; color: #64748b; }

        @keyframes badgePulse {
          0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(244, 63, 94, 0.4); }
          70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(244, 63, 94, 0); }
          100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(244, 63, 94, 0); }
        }
        @keyframes spin { 100% { transform: rotate(360deg); } }
      `}</style>
		</div>
	);
}
