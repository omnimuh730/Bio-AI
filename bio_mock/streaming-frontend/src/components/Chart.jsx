import React, { useEffect, useState } from "react";

// --- Styles ---
const styles = {
	container: {
		padding: "2rem",
		fontFamily: "'Inter', sans-serif",
		background: "#f3f4f6",
		minHeight: "100vh",
	},
	header: { marginBottom: "2rem" },
	grid: {
		display: "grid",
		gridTemplateColumns: "repeat(auto-fit, minmax(400px, 1fr))",
		gap: "2rem",
	},
	deviceCard: {
		background: "white",
		borderRadius: "16px",
		padding: "1.5rem",
		boxShadow: "0 4px 6px -1px rgba(0, 0, 0, 0.1)",
	},
	deviceTitle: {
		borderBottom: "1px solid #eee",
		paddingBottom: "1rem",
		marginBottom: "1rem",
		fontSize: "1.25rem",
		fontWeight: "bold",
		color: "#111827",
	},
	metricRow: {
		display: "flex",
		justifyContent: "space-between",
		alignItems: "center",
		marginBottom: "0.75rem",
		padding: "0.5rem",
		borderRadius: "8px",
		background: "#f9fafb",
	},
	metricLabel: {
		fontSize: "0.875rem",
		color: "#6b7280",
		textTransform: "capitalize",
	},
	metricValue: {
		fontWeight: "600",
		color: "#111827",
		fontSize: "1rem",
		fontVariantNumeric: "tabular-nums",
	},
	unit: { fontSize: "0.75rem", color: "#9ca3af", marginLeft: "4px" },
	sparkline: { marginLeft: "1rem" },
};

// --- Mini Sparkline ---
const MiniSparkline = ({ history = [], color = "#3b82f6" }) => {
	if (history.length < 5) return null;
	const h = 30;
	const w = 100;
	const max = Math.max(...history);
	const min = Math.min(...history);
	const points = history
		.map((v, i) => {
			const x = (i / (history.length - 1)) * w;
			const y = h - ((v - min) / (max - min || 1)) * h;
			return `${x},${y}`;
		})
		.join(" ");

	return (
		<svg width={w} height={h} style={styles.sparkline}>
			<polyline
				points={points}
				fill="none"
				stroke={color}
				strokeWidth="2"
				strokeLinecap="round"
			/>
		</svg>
	);
};

// --- Main Component ---
export default function EcosystemDashboard() {
	const [ecosystem, setEcosystem] = useState({});

	useEffect(() => {
		const evtSource = new EventSource(
			"http://localhost:8000/api/stream/ecosystem",
		);

		evtSource.onmessage = (e) => {
			const batch = JSON.parse(e.data);

			setEcosystem((prev) => {
				const next = { ...prev };

				batch.forEach((item) => {
					const { device_id, type, value, unit } = item;

					if (!next[device_id]) next[device_id] = {};
					if (!next[device_id][type])
						next[device_id][type] = {
							current: value,
							unit,
							history: [],
						};

					// Update Current Value
					next[device_id][type].current = value;

					// Update History (keep last 20 points for sparklines)
					// Note: In categorical data (strings), we don't push to history for sparklines
					if (typeof value === "number") {
						const h = next[device_id][type].history;
						next[device_id][type].history = [...h, value].slice(
							-30,
						);
					}
				});

				return next;
			});
		};

		return () => evtSource.close();
	}, []);

	return (
		<div style={styles.container}>
			<div style={styles.header}>
				<h1
					style={{
						fontSize: "2rem",
						fontWeight: "800",
						color: "#1f2937",
					}}
				>
					Health Data Exchange
				</h1>
				<p style={{ color: "#6b7280" }}>
					Live stream from 4 heterogeneous wearable sources
				</p>
			</div>

			<div style={styles.grid}>
				{Object.entries(ecosystem).map(([deviceName, metrics]) => (
					<div key={deviceName} style={styles.deviceCard}>
						<div style={styles.deviceTitle}>
							{getIcon(deviceName)} {deviceName}
						</div>

						{Object.entries(metrics).map(([metricKey, data]) => (
							<div key={metricKey} style={styles.metricRow}>
								<div
									style={{
										display: "flex",
										flexDirection: "column",
									}}
								>
									<span style={styles.metricLabel}>
										{metricKey.replace(/_/g, " ")}
									</span>
									<div>
										<span style={styles.metricValue}>
											{data.current}
										</span>
										<span style={styles.unit}>
											{data.unit}
										</span>
									</div>
								</div>
								{typeof data.current === "number" && (
									<MiniSparkline
										history={data.history}
										color={getColor(deviceName)}
									/>
								)}
							</div>
						))}
					</div>
				))}
			</div>
		</div>
	);
}

// Helpers for visual flair
const getIcon = (name) => {
	if (name.includes("Apple")) return "";
	if (name.includes("Samsung")) return "S";
	if (name.includes("Garmin")) return "▲";
	if (name.includes("Pixel")) return "G";
	return "⌚";
};

const getColor = (name) => {
	if (name.includes("Apple")) return "#ef4444"; // Red ring
	if (name.includes("Samsung")) return "#3b82f6"; // Blue
	if (name.includes("Garmin")) return "#f59e0b"; // Orange
	if (name.includes("Pixel")) return "#10b981"; // Green
	return "#666";
};
