/**
 * LiveVitals.jsx
 * - Dashboard component showing extended watch-style metrics (HR, SpO2, Steps, VO2, etc.)
 * - Includes an animated, streaming heart-rate chart that can Start/Stop live streaming.
 * - Streaming simulation appends new HR points at intervals, animates a left-shift of the chart,
 *   trims old points, and updates metric tiles to mimic a real live stream.
 *
 * To integrate a real live source, replace the simulated interval with a WebSocket / EventSource
 * or subscribe to your streaming API and push values into `addHrPoint()` as they arrive.
 */
import React from "react";
import {
	FiRefreshCw,
	FiActivity,
	FiCpu,
	FiHeart,
	FiFlag,
	FiSun,
	FiBatteryCharging,
} from "react-icons/fi";

// Extended mock metrics similar to Apple Watch / Garmin / Fitbit
const initialVitals = [
	{
		key: "resting_hr",
		label: "Resting HR",
		value: 58,
		unit: "bpm",
		icon: <FiHeart />,
		color: "#ef4444",
	},
	{
		key: "hrv",
		label: "HRV (SDNN)",
		value: 42,
		unit: "ms",
		icon: <FiActivity />,
		color: "#8b5cf6",
	},
	{
		key: "stress",
		label: "Stress",
		value: "Low",
		unit: "12%",
		icon: <FiCpu />,
		color: "#10b981",
	},
	{
		key: "spo2",
		label: "SpO2",
		value: 98,
		unit: "%",
		icon: <FiFlag />,
		color: "#06b6d4",
	},
	{
		key: "steps",
		label: "Steps",
		value: 8245,
		unit: "steps",
		icon: <FiSun />,
		color: "#f59e0b",
	},
	{
		key: "active_cal",
		label: "Active Cal",
		value: 512,
		unit: "kcal",
		icon: <FiBatteryCharging />,
		color: "#ef4444",
	},
	{
		key: "sleep",
		label: "Sleep",
		value: "7h 12m",
		unit: "",
		icon: <FiFlag />,
		color: "#a78bfa",
	},
	{
		key: "vo2",
		label: "VO2 Max",
		value: 44,
		unit: "ml/kg/min",
		icon: <FiActivity />,
		color: "#6366f1",
	},
	{
		key: "resp",
		label: "Resp Rate",
		value: 14,
		unit: "rpm",
		icon: <FiActivity />,
		color: "#06b6d4",
	},
	{
		key: "temp",
		label: "Body Temp",
		value: 36.6,
		unit: "°C",
		icon: <FiSun />,
		color: "#fb7185",
	},
];

function HeartRateChart({
	data = [],
	color = "#ef4444",
	isShifting = false,
	animationMs = 300,
	maxWidth = 300,
}) {
	// Streaming-friendly SVG chart:
	// - When `data` has one extra point (incoming), a left translate of the plot by `dx` pixels
	//   animates a smooth shift. After the animation completes the parent should trim the first point.
	const width = maxWidth;
	const height = 60;
	const padding = 8;
	if (!data.length) return null;

	const max = Math.max(...data);
	const min = Math.min(...data);
	const points = data.map((d, i) => {
		const x = (i / (data.length - 1)) * (width - padding * 2) + padding;
		const y =
			((max - d) / (max - min || 1)) * (height - padding * 2) + padding;
		return `${x},${y}`;
	});
	const pathD = `M${points.join(" L")}`;
	const dx = (width - padding * 2) / Math.max(1, data.length - 1);

	return (
		<div className="hr-chart">
			<svg viewBox={`0 0 ${width} ${height}`} preserveAspectRatio="none">
				<defs>
					<linearGradient id="grad" x1="0" x2="1">
						<stop
							offset="0%"
							stopColor={color}
							stopOpacity="0.25"
						/>
						<stop offset="100%" stopColor={color} stopOpacity="0" />
					</linearGradient>
				</defs>
				{/* group we translate to produce the left-shift animation */}
				<g
					className={`plot ${isShifting ? "shifting" : ""}`}
					style={{
						transform: isShifting ? `translateX(-${dx}px)` : "none",
					}}
				>
					<path
						d={pathD}
						fill="none"
						stroke={color}
						strokeWidth="2"
						strokeLinecap="round"
						strokeLinejoin="round"
					/>
					<path
						d={`${pathD} L ${width - padding},${height} L ${padding},${height} Z`}
						fill="url(#grad)"
						opacity="0.75"
					/>
				</g>
			</svg>
			<style>{`
				.hr-chart { width: 100%; max-width: ${width}px; margin: 8px 0; }
				.plot { transition: none; }
				.plot.shifting { transition: transform ${animationMs}ms linear; }
			`}</style>
		</div>
	);
}

export default function LiveVitals() {
	const [loading, setLoading] = React.useState(false);
	const [vitals, setVitals] = React.useState(initialVitals);
	const MAX_POINTS = 40;
	const ANIM_MS = 300; // animation duration for shift
	const [hrSeries, setHrSeries] = React.useState(() => {
		// fill initial series to MAX_POINTS with smoothing
		const base = [68, 70, 72, 69, 75, 80, 76, 74, 72, 70];
		while (base.length < MAX_POINTS) base.unshift(base[0]);
		return base;
	});

	const [animateKey, setAnimateKey] = React.useState("k0");
	const [isLive, setIsLive] = React.useState(false);
	const [isShiftingChart, setIsShiftingChart] = React.useState(false);
	const intervalRef = React.useRef(null);

	// helper to append a new HR point and animate shift
	const addHrPoint = (newHr) => {
		// append new point (series grows by 1)
		setHrSeries((prev) => {
			const next = prev.concat([newHr]);
			return next;
		});
		// trigger shift animation
		setIsShiftingChart(true);
		// after animation, remove the oldest point and stop shifting
		setTimeout(() => {
			setHrSeries((p) => p.slice(1));
			setIsShiftingChart(false);
			// update visible resting HR tile to latest value
			setVitals((prev) =>
				prev.map((x) =>
					x.key === "resting_hr" ? { ...x, value: newHr } : x,
				),
			);
		}, ANIM_MS);
	};

	const startLive = () => {
		if (intervalRef.current) return;
		setIsLive(true);
		intervalRef.current = setInterval(() => {
			// streaming tick: generate HR with small random walk
			setHrSeries((prev) => {
				const last = prev[prev.length - 1] || 70;
				const nextHr = Math.max(
					40,
					Math.min(
						190,
						last +
							(Math.random() > 0.5 ? 1 : -1) *
								Math.round(Math.random() * 3),
					),
				);
				// we don't mutate here — call addHrPoint to ensure consistent animation timing
				addHrPoint(nextHr);
				return prev; // addHrPoint already handles state changes
			});
			// update a couple of other tiles occasionally to simulate streaming updates
			setVitals((prev) =>
				prev.map((p) => {
					if (p.key === "steps")
						return {
							...p,
							value: p.value + Math.round(Math.random() * 30),
						};
					if (p.key === "active_cal")
						return {
							...p,
							value: p.value + Math.round(Math.random() * 3),
						};
					return p;
				}),
			);
		}, 1000);
	};

	const stopLive = () => {
		setIsLive(false);
		if (intervalRef.current) {
			clearInterval(intervalRef.current);
			intervalRef.current = null;
		}
	};

	React.useEffect(() => {
		return () => stopLive();
	}, []);

	const handleRefresh = () => {
		setLoading(true);
		// quick snapshot refresh (non-streaming)
		setTimeout(() => {
			setVitals((prev) =>
				prev.map((p) => {
					if (p.key === "resting_hr")
						return {
							...p,
							value: Math.round(58 + Math.random() * 10),
						};
					if (p.key === "spo2")
						return {
							...p,
							value: Math.max(
								94,
								Math.min(
									100,
									p.value + (Math.random() > 0.5 ? 1 : -1),
								),
							),
						};
					if (p.key === "steps")
						return {
							...p,
							value: p.value + Math.round(Math.random() * 120),
						};
					return p;
				}),
			);

			// snapshot HR series refresh
			setHrSeries((s) =>
				s.slice(-9).concat([Math.round(60 + Math.random() * 40)]),
			);
			setAnimateKey(`k${Date.now()}`);
			setLoading(false);
		}, 800);
	};

	return (
		<div className="card live-vitals">
			<div className="card-title">
				Live Vitals
				<div
					style={{
						display: "inline-flex",
						gap: 8,
						marginLeft: 12,
						alignItems: "center",
					}}
				>
					<button
						className={`refresh ${loading ? "spinning" : ""}`}
						onClick={handleRefresh}
						title="Refresh"
					>
						<FiRefreshCw />
					</button>
					<button
						className={`live-toggle ${isLive ? "live-on" : ""}`}
						onClick={() => (isLive ? stopLive() : startLive())}
					>
						{isLive ? "Stop Live" : "Start Live"}
					</button>
				</div>
			</div>

			{/* Heart rate chart + current HR highlight */}
			<div className="chart-row">
				<div className="chart-left">
					<div className="hr-current">
						<div className="hr-val">
							{hrSeries[hrSeries.length - 1]}{" "}
							<span className="unit">bpm</span>
						</div>
						<div className="hr-label">
							Resting HR {isLive ? "• live" : ""}
						</div>
					</div>
					<HeartRateChart
						data={hrSeries}
						color={vitals.find((v) => v.key === "resting_hr").color}
						isShifting={isShiftingChart}
						animationMs={ANIM_MS}
						maxWidth={460}
					/>
				</div>
				<div className="chart-right">
					<div className="spark-grid">
						{vitals.slice(0, 9).map((item) => (
							<div key={item.key} className="vital-item small">
								<div
									className="vital-icon"
									style={{
										color: item.color,
										backgroundColor: `${item.color}15`,
									}}
								>
									{item.icon}
								</div>
								<div className="vital-data">
									<div className="val">
										{item.value}{" "}
										<span className="unit">
											{item.unit}
										</span>
									</div>
									<div className="lbl">{item.label}</div>
								</div>
							</div>
						))}
					</div>
				</div>
			</div>

			<style>{`
				.chart-row { display: flex; gap: 12px; align-items: center; }
				.chart-left { flex: 1; }
				.chart-right { width: 340px; }
				.hr-current { display: flex; align-items: baseline; gap: 12px; }
				.hr-val { font-weight: 900; font-size: 28px; color: #0f172a; }
				.hr-val .unit { font-size: 12px; color: #94a3b8; font-weight: 700; }
				.hr-label { color: #64748b; font-weight: 700; font-size: 12px; }
				.spark-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; }
				.vital-item.small { display: flex; align-items: center; gap: 8px; padding: 8px; background: #fbfcfe; border-radius: 10px; }
				.vital-item.small .vital-icon { width: 36px; height: 36px; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 16px; }
				.vital-item.small .val { font-weight: 800; font-size: 13px; }

				/* Live toggle */
				.live-toggle { background: transparent; border: 1px solid #e2e8f0; padding: 6px 10px; border-radius: 8px; cursor: pointer; font-weight: 700; }
				.live-toggle.live-on { background: linear-gradient(90deg,#ef4444,#f59e0b); color: white; border: none; }

				/* Responsive tweaks */
				@media (max-width: 880px) { .chart-row { flex-direction: column; } .chart-right { width: 100%; } }
				/* refresh animation */
				.spinning { transform: rotate(360deg); transition: transform 1s linear; }
			`}</style>
		</div>
	);
}
