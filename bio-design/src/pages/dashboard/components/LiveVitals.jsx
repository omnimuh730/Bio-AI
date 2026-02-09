import React, { useState, useEffect, useRef } from "react";
import {
	FiRefreshCw,
	FiActivity,
	FiCpu,
	FiHeart,
	FiWind,
	FiZap,
	FiMoon,
	FiDroplet,
	FiThermometer,
} from "react-icons/fi";

// --- Configuration ---
const CONFIG = {
	colors: {
		primary: "#f43f5e", // Rose
	},
};

const initialVitals = [
	{
		key: "hrv",
		label: "HRV",
		value: 42,
		unit: "ms",
		icon: <FiActivity />,
		color: "#8b5cf6",
		bg: "#f5f3ff",
	},
	{
		key: "stress",
		label: "Stress",
		value: "12",
		unit: "%",
		icon: <FiCpu />,
		color: "#10b981",
		bg: "#ecfdf5",
	},
	{
		key: "spo2",
		label: "SpO2",
		value: 98,
		unit: "%",
		icon: <FiWind />,
		color: "#06b6d4",
		bg: "#ecfeff",
	},
	{
		key: "steps",
		label: "Steps",
		value: "8,245",
		unit: "",
		icon: <FiZap />,
		color: "#f59e0b",
		bg: "#fffbeb",
	},
	{
		key: "sleep",
		label: "Sleep",
		value: "7h 12m",
		unit: "",
		icon: <FiMoon />,
		color: "#6366f1",
		bg: "#eef2ff",
	},
	{
		key: "vo2",
		label: "VO2 Max",
		value: 44,
		unit: "",
		icon: <FiDroplet />,
		color: "#3b82f6",
		bg: "#eff6ff",
	},
	{
		key: "resp",
		label: "Resp Rate",
		value: 14,
		unit: "rpm",
		icon: <FiWind />,
		color: "#14b8a6",
		bg: "#f0fdfa",
	},
	{
		key: "temp",
		label: "Temp",
		value: 36.6,
		unit: "°C",
		icon: <FiThermometer />,
		color: "#f43f5e",
		bg: "#fff1f2",
	},
];

/**
 * Smoothes points into a bezier curve path for SVG
 */
function getSplinePath(data, width, height, padding = 0) {
	if (data.length === 0) return "";
	const max = Math.max(...data, 100);
	const min = Math.min(...data, 40);
	const range = max - min || 1;

	const points = data.map((val, i) => {
		const x = (i / (data.length - 1)) * width;
		const y =
			height - ((val - min) / range) * (height - padding * 2) - padding;
		return [x, y];
	});

	const controlPoint = (current, previous, next, reverse) => {
		const p = previous || current;
		const n = next || current;
		const smoothing = 0.2;
		const o = line(p, n);
		const angle = o.angle + (reverse ? Math.PI : 0);
		const length = o.length * smoothing;
		const x = current[0] + Math.cos(angle) * length;
		const y = current[1] + Math.sin(angle) * length;
		return [x, y];
	};

	const line = (pointA, pointB) => {
		const lengthX = pointB[0] - pointA[0];
		const lengthY = pointB[1] - pointA[1];
		return {
			length: Math.sqrt(Math.pow(lengthX, 2) + Math.pow(lengthY, 2)),
			angle: Math.atan2(lengthY, lengthX),
		};
	};

	return points.reduce((acc, point, i, a) => {
		if (i === 0) return `M ${point[0]},${point[1]}`;
		const cps = controlPoint(a[i - 1], a[i - 2], point);
		const cpe = controlPoint(point, a[i - 1], a[i + 1], true);
		return `${acc} C ${cps[0]},${cps[1]} ${cpe[0]},${cpe[1]} ${point[0]},${point[1]}`;
	}, "");
}

function HeartRateHero({ data, isLive }) {
	const containerRef = useRef(null);
	const [dims, setDims] = useState({ width: 0, height: 120 });

	// Handle Resize safely to prevent overflow
	useEffect(() => {
		const updateDims = () => {
			if (containerRef.current) {
				setDims({
					width: containerRef.current.getBoundingClientRect().width,
					height: 120,
				});
			}
		};

		// Initial size
		updateDims();

		window.addEventListener("resize", updateDims);
		return () => window.removeEventListener("resize", updateDims);
	}, []);

	const pathD =
		dims.width > 0 ? getSplinePath(data, dims.width, dims.height, 10) : "";
	// FIX: Ensure we round the displayed value so it doesn't break layout
	const lastVal = Math.round(data[data.length - 1]);

	return (
		<div className="hero-card">
			<div className="hero-header">
				<div className="hero-left">
					<div className="hero-icon">
						<FiHeart />
					</div>
					<div className="hero-text">
						<div className="hero-label">Resting HR</div>
						<div className="hero-meta">
							{isLive && <span className="live-dot" />}
							{isLive ? "Live" : "1m ago"}
						</div>
					</div>
				</div>

				<div className="hero-value-container">
					<span className="hero-value">{lastVal}</span>
					<span className="hero-unit">bpm</span>
				</div>
			</div>

			<div className="hero-chart" ref={containerRef}>
				{dims.width > 0 && (
					<svg
						width={dims.width}
						height={dims.height}
						viewBox={`0 0 ${dims.width} ${dims.height}`}
						preserveAspectRatio="none"
						className="chart-svg"
					>
						<defs>
							<linearGradient
								id="gradientDetails"
								x1="0"
								x2="0"
								y1="0"
								y2="1"
							>
								<stop
									offset="0%"
									stopColor={CONFIG.colors.primary}
									stopOpacity="0.3"
								/>
								<stop
									offset="100%"
									stopColor={CONFIG.colors.primary}
									stopOpacity="0.0"
								/>
							</linearGradient>
						</defs>
						<path
							d={`${pathD} L ${dims.width},${dims.height} L 0,${dims.height} Z`}
							fill="url(#gradientDetails)"
						/>
						<path
							d={pathD}
							fill="none"
							stroke={CONFIG.colors.primary}
							strokeWidth="3"
							strokeLinecap="round"
						/>
					</svg>
				)}
			</div>

			<style>{`
        .hero-card {
          background: white;
          border-radius: 24px;
          padding: 20px;
          box-shadow: 0 10px 30px -10px rgba(244, 63, 94, 0.15);
          border: 1px solid rgba(244, 63, 94, 0.1);
          margin-bottom: 20px;
          position: relative;
          overflow: hidden; /* Critical for containing chart overflow */
        }

        .hero-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 10px;
          position: relative;
          z-index: 2;
        }

        .hero-left {
          display: flex;
          align-items: center;
          gap: 12px;
          min-width: 0; /* Flexbox shrink fix */
        }

        .hero-icon { 
          width: 40px; height: 40px; flex-shrink: 0;
          border-radius: 12px; 
          background: #fff1f2; color: #f43f5e; 
          display: flex; align-items: center; justify-content: center; 
          font-size: 20px;
        }

        .hero-text {
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .hero-label { font-size: 13px; font-weight: 600; color: #64748b; }
        .hero-meta { font-size: 11px; color: #94a3b8; display: flex; align-items: center; gap: 6px; font-weight: 500; }

        .hero-value-container {
          text-align: right;
          white-space: nowrap;
          flex-shrink: 0;
        }
        
        .hero-value { font-size: 32px; font-weight: 800; color: #0f172a; letter-spacing: -1px; line-height: 1; }
        .hero-unit { font-size: 13px; font-weight: 600; color: #94a3b8; margin-left: 4px; }
        
        .live-dot { width: 6px; height: 6px; background: #f43f5e; border-radius: 50%; animation: pulseRed 1.5s infinite; }
        @keyframes pulseRed {
          0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(244, 63, 94, 0.7); }
          70% { transform: scale(1); box-shadow: 0 0 0 6px rgba(244, 63, 94, 0); }
          100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(244, 63, 94, 0); }
        }
        
        .hero-chart { height: 120px; width: 100%; margin-top: -15px; }
        .chart-svg { display: block; overflow: visible; }
      `}</style>
		</div>
	);
}

export default function LiveVitals() {
	const [isLive, setIsLive] = useState(false);
	// FIX: Initialize with rounded integers to prevent initial flash of decimals
	const [hrData, setHrData] = useState(() =>
		Array.from({ length: 30 }, () => Math.round(60 + Math.random() * 10)),
	);
	const [vitals, setVitals] = useState(initialVitals);
	const [loading, setLoading] = useState(false);
	const intervalRef = useRef(null);

	useEffect(() => {
		if (isLive) {
			intervalRef.current = setInterval(() => {
				setHrData((prev) => {
					const last = prev[prev.length - 1];
					// Ensure calculation results in integer
					const nextVal = last + (Math.random() - 0.5) * 8;
					const clamped = Math.max(50, Math.min(180, nextVal));
					const rounded = Math.round(clamped);

					return [...prev.slice(1), rounded];
				});

				if (Math.random() > 0.7) {
					setVitals((prev) =>
						prev.map((v) =>
							v.key === "steps"
								? {
										...v,
										value: (
											parseInt(
												v.value
													.toString()
													.replace(/,/g, ""),
											) + Math.ceil(Math.random() * 5)
										).toLocaleString(),
									}
								: v,
						),
					);
				}
			}, 800);
		} else {
			if (intervalRef.current) clearInterval(intervalRef.current);
		}
		return () => clearInterval(intervalRef.current);
	}, [isLive]);

	const toggleLive = () => setIsLive(!isLive);
	const refresh = () => {
		setLoading(true);
		setTimeout(() => {
			// FIX: Ensure refresh data is also rounded
			setHrData(
				Array.from({ length: 30 }, () =>
					Math.round(60 + Math.random() * 10),
				),
			);
			setLoading(false);
		}, 1000);
	};

	return (
		<div className="dashboard-container">
			<div className="dashboard-header">
				<h2 className="title">My Vitals</h2>
				<div className="actions">
					<button
						className={`btn-icon ${loading ? "spin" : ""}`}
						onClick={refresh}
					>
						<FiRefreshCw />
					</button>
					<button
						className={`btn-pill ${isLive ? "active" : ""}`}
						onClick={toggleLive}
					>
						{isLive ? "Stop Live" : "Go Live"}
					</button>
				</div>
			</div>

			<HeartRateHero data={hrData} isLive={isLive} />

			<div className="vitals-grid">
				{vitals.map((item) => (
					<div key={item.key} className="vital-card">
						<div className="card-top">
							<div
								className="icon-box"
								style={{
									color: item.color,
									background: item.bg,
								}}
							>
								{item.icon}
							</div>
							{item.key === "stress" && (
								<span className="badge-low">Low</span>
							)}
						</div>
						<div className="card-content">
							<div className="card-value">
								{item.value}
								<span className="card-unit">{item.unit}</span>
							</div>
							<div className="card-label">{item.label}</div>
						</div>
					</div>
				))}
			</div>

			<style>{`
        /* Global Reset for box-sizing */
        * { box-sizing: border-box; }

        .dashboard-container {
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
          width: 100%;
          max-width: 480px; 
          margin: 0 auto;
          background: #f8fafc;
          padding: 20px;
          border-radius: 32px;
          overflow-x: hidden; /* Prevents container scroll */
        }
        
        .dashboard-header {
          display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;
        }
        .title { font-size: 22px; font-weight: 800; color: #0f172a; margin: 0; letter-spacing: -0.5px; }
        .actions { display: flex; gap: 10px; }

        .btn-icon {
          background: white; border: 1px solid #e2e8f0; color: #64748b;
          width: 36px; height: 36px; border-radius: 50%;
          display: flex; align-items: center; justify-content: center; cursor: pointer;
          transition: all 0.2s ease;
        }
        .btn-icon.spin svg { animation: spin 0.8s linear infinite; }
        
        .btn-pill {
          background: #0f172a; color: white; border: none;
          padding: 0 16px; height: 36px; border-radius: 18px;
          font-size: 13px; font-weight: 600; cursor: pointer;
          transition: all 0.2s ease; white-space: nowrap;
        }
        .btn-pill.active { background: #f43f5e; box-shadow: 0 4px 12px rgba(244, 63, 94, 0.4); }

        .vitals-grid {
          display: grid; 
          grid-template-columns: repeat(2, 1fr); 
          gap: 12px;
        }

        .vital-card {
          background: white; border-radius: 20px; padding: 16px;
          display: flex; flex-direction: column; gap: 12px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.02);
          border: 1px solid #f1f5f9;
        }

        .card-top { display: flex; justify-content: space-between; align-items: flex-start; }
        .icon-box {
          width: 36px; height: 36px; border-radius: 12px;
          display: flex; align-items: center; justify-content: center;
          font-size: 18px;
        }
        .badge-low {
          background: #ecfdf5; color: #10b981; font-size: 10px; font-weight: 700;
          padding: 4px 8px; border-radius: 10px; text-transform: uppercase;
        }

        .card-content { display: flex; flex-direction: column; gap: 2px; }
        
        /* Prevent overflow in small cards */
        .card-value { 
          font-size: 18px; font-weight: 700; color: #0f172a; 
          white-space: nowrap; overflow: hidden; text-overflow: ellipsis; 
        }
        .card-unit { font-size: 12px; color: #94a3b8; font-weight: 600; margin-left: 2px; }
        .card-label { font-size: 12px; font-weight: 500; color: #64748b; }

        @keyframes spin { 100% { transform: rotate(360deg); } }
      `}</style>
		</div>
	);
}
