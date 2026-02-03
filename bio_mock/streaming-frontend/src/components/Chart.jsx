import React, { useEffect, useState, useRef } from "react";

// --- Colors & Branding ---
const BRAND_COLORS = {
	Apple: "#000000",
	Samsung: "#1428a0",
	Garmin: "#007cc3",
	Fitbit: "#00b0b9",
	Oura: "#d4af37", // Gold
	Whoop: "#cf2e2e",
	Huawei: "#c7000b",
	Withings: "#4a4a4a",
	OnePlus: "#f50000",
	Amazfit: "#30d19e",
};

const getBrandColor = (deviceName) => {
	const key = Object.keys(BRAND_COLORS).find((k) => deviceName.includes(k));
	return BRAND_COLORS[key] || "#555";
};

// --- Components ---

const MetricRow = ({ label, value, unit, color }) => {
	// Determine Visualizer Type
	const isPercent = unit === "%" || label.includes("score");
	const isWave = label.includes("ecg") || label.includes("accel");
	const isLoc = unit === "loc";

	return (
		<div style={{ marginBottom: 8, fontSize: 13 }}>
			<div
				style={{
					display: "flex",
					justifyContent: "space-between",
					marginBottom: 2,
				}}
			>
				<span
					style={{
						color: "#666",
						textTransform: "uppercase",
						fontSize: 11,
						fontWeight: 600,
					}}
				>
					{label.replace(/_/g, " ")}
				</span>
				<span style={{ fontFamily: "monospace", fontWeight: 600 }}>
					{value}{" "}
					<span style={{ color: "#999", fontSize: 10 }}>{unit}</span>
				</span>
			</div>

			{/* Conditional Visuals */}
			{isPercent && (
				<div style={{ height: 4, background: "#eee", borderRadius: 2 }}>
					<div
						style={{
							width: `${Math.min(value, 100)}%`,
							height: "100%",
							background: color,
							borderRadius: 2,
						}}
					/>
				</div>
			)}

			{isWave && (
				<div
					style={{
						height: 2,
						background: "#eee",
						marginTop: 4,
						position: "relative",
						overflow: "hidden",
					}}
				>
					<div
						style={{
							position: "absolute",
							left: 0,
							top: 0,
							bottom: 0,
							width: "50%",
							background: `linear-gradient(90deg, transparent, ${color})`,
							transform: "translateX(100%)",
							animation: "dash 0.5s linear infinite",
						}}
					/>
				</div>
			)}

			{isLoc && (
				<div style={{ fontSize: 10, color: "#aaa" }}>
					Live GPS Tracking Active
				</div>
			)}
		</div>
	);
};

// Small switchbox component
const SwitchBox = ({ checked, onChange }) => {
	return (
		<label style={{ display: "inline-flex", alignItems: "center", gap: 8 }}>
			<input
				type="checkbox"
				checked={checked}
				onChange={(e) => onChange(e.target.checked)}
				style={{ width: 40, height: 20 }}
			/>
			<span style={{ fontSize: 12, color: checked ? "#111" : "#888" }}>
				{checked ? "On" : "Off"}
			</span>
		</label>
	);
};

const DeviceCard = ({ name, hz, metrics, count, available, onToggle }) => {
	const color = getBrandColor(name);

	return (
		<div
			style={{
				background: "white",
				borderRadius: 12,
				overflow: "hidden",
				boxShadow: "0 4px 12px rgba(0,0,0,0.08)",
				display: "flex",
				flexDirection: "column",
			}}
		>
			{/* Header */}
			<div
				style={{
					background: color,
					padding: "12px 16px",
					display: "flex",
					justifyContent: "space-between",
					alignItems: "center",
				}}
			>
				<h3
					style={{
						margin: 0,
						color: "white",
						fontSize: 15,
						fontWeight: 600,
					}}
				>
					{name}
				</h3>
				<div style={{ display: "flex", alignItems: "center", gap: 12 }}>
					<span
						style={{
							background: "rgba(255,255,255,0.2)",
							color: "white",
							fontSize: 10,
							padding: "2px 6px",
							borderRadius: 4,
						}}
					>
						{hz} Hz
					</span>
					{/* Switch */}
					<SwitchBox checked={available} onChange={onToggle} />
				</div>
			</div>

			{/* Body */}
			<div style={{ padding: 16 }}>
				{Object.entries(metrics).map(([key, data]) => (
					<MetricRow
						key={key}
						label={key}
						value={data.value}
						unit={data.unit}
						color={color}
					/>
				))}
			</div>

			{/* Footer */}
			<div
				style={{
					marginTop: "auto",
					padding: "8px 16px",
					background: "#f8f9fa",
					borderTop: "1px solid #eee",
					fontSize: 10,
					color: "#aaa",
					textAlign: "right",
				}}
			>
				Packets Received: {count.toLocaleString()}
			</div>
		</div>
	);
};

export default function EcosystemDashboard() {
	const [devices, setDevices] = useState({});
	const [meta, setMeta] = useState({});
	const [available, setAvailable] = useState([]);
	const dataRef = useRef({});

	useEffect(() => {
		// Inject CSS for the wave animation
		const style = document.createElement("style");
		style.innerHTML = `@keyframes dash { 0% { transform: translateX(-100%); } 100% { transform: translateX(200%); } }`;
		document.head.appendChild(style);

		const es = new EventSource("http://localhost:8000/api/stream/all");

		es.onmessage = (e) => {
			const msg = JSON.parse(e.data);
			const { device, hz, metrics } = msg;

			// Update ref (buffer)
			if (!dataRef.current[device]) {
				dataRef.current[device] = { hz, metrics, count: 0 };
			}
			dataRef.current[device].metrics = metrics;
			dataRef.current[device].count++;
		};

		// Render loop: 15 FPS is enough for human eyes on a dashboard
		const interval = setInterval(() => {
			setDevices({ ...dataRef.current });
		}, 66);

		// Fetch meta & available list on mount
		fetch("http://localhost:8000/api/devices")
			.then((r) => r.json())
			.then((d) => {
				const map = {};
				d.devices.forEach((it) => (map[it.name] = it));
				setMeta(map);
			})
			.catch(() => {});

		fetch("http://localhost:8000/api/available")
			.then((r) => r.json())
			.then((d) => setAvailable(d.available || []))
			.catch(() => setAvailable([]));

		// Poll available every 5s so UI stays in sync if other clients change it
		const poll = setInterval(() => {
			fetch("http://localhost:8000/api/available")
				.then((r) => r.json())
				.then((d) => setAvailable(d.available || []))
				.catch(() => {});
		}, 5000);

		return () => {
			es.close();
			clearInterval(interval);
			clearInterval(poll);
		};
	}, []);

	const toggleExposure = (name, on) => {
		const url = `http://localhost:8000/api/${on ? "expose" : "hide"}`;
		fetch(url, {
			method: "POST",
			headers: { "Content-Type": "application/json" },
			body: JSON.stringify({ device: name }),
		})
			.then((r) => r.json())
			.then((d) => {
				// backend returns available list
				if (d.available) setAvailable(d.available);
			})
			.catch(() => {});
	};

	return (
		<div
			style={{
				padding: 32,
				background: "#f3f4f6",
				minHeight: "100vh",
				fontFamily: "system-ui, sans-serif",
			}}
		>
			<div style={{ marginBottom: 16 }}>
				<h1 style={{ margin: "0 0 8px 0", color: "#111" }}>
					Global Health Stream
				</h1>
				<p style={{ margin: 0, color: "#666" }}>
					Real-time emulation of {Object.keys(devices).length}{" "}
					heterogeneous wearable devices.
				</p>
			</div>

			{/* Available Devices Panel */}
			<div
				style={{
					marginBottom: 24,
					display: "flex",
					gap: 16,
					alignItems: "center",
				}}
			>
				<div
					style={{
						padding: 12,
						background: "white",
						borderRadius: 10,
						boxShadow: "0 2px 8px rgba(0,0,0,0.06)",
					}}
				>
					<strong style={{ display: "block", marginBottom: 6 }}>
						Available Devices
					</strong>
					<div style={{ fontSize: 13, color: "#444" }}>
						{available.length} device(s)
					</div>
					<div style={{ marginTop: 8, fontSize: 12, color: "#666" }}>
						{available.join(", ") || "—"}
					</div>
				</div>
				<div
					style={{
						padding: 12,
						background: "white",
						borderRadius: 10,
						boxShadow: "0 2px 8px rgba(0,0,0,0.06)",
					}}
				>
					<strong style={{ display: "block", marginBottom: 6 }}>
						All Known Devices
					</strong>
					<div style={{ fontSize: 13, color: "#444" }}>
						{Object.keys(meta).length} total
					</div>
				</div>
			</div>

			<div
				style={{
					display: "grid",
					gridTemplateColumns:
						"repeat(auto-fill, minmax(300px, 1fr))",
					gap: 24,
				}}
			>
				{Object.keys({ ...meta, ...devices })
					.sort()
					.map((name) => (
						<DeviceCard
							key={name}
							name={name}
							hz={(devices[name] || meta[name] || {}).hz || "—"}
							metrics={
								(devices[name] && devices[name].metrics) || {}
							}
							count={(devices[name] && devices[name].count) || 0}
							available={available.includes(name)}
							onToggle={(on) => toggleExposure(name, on)}
						/>
					))}
			</div>
		</div>
	);
}
