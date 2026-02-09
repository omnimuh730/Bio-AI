import React, { useState } from "react";
import {
	FiChevronLeft,
	FiRefreshCw,
	FiCheckCircle,
	FiXCircle,
} from "react-icons/fi";

const DeviceItem = ({ name, icon, connected }) => {
	const [syncing, setSyncing] = useState(false);

	const handleSync = (e) => {
		e.stopPropagation();
		if (!connected) return;
		setSyncing(true);
		setTimeout(() => setSyncing(false), 2000);
	};

	return (
		<div
			style={{
				background: "white",
				borderRadius: 20,
				padding: 16,
				marginBottom: 12,
				display: "flex",
				alignItems: "center",
				gap: 16,
				boxShadow: "0 4px 12px rgba(0,0,0,0.03)",
				border: "1px solid rgba(0,0,0,0.02)",
			}}
		>
			<div
				style={{
					width: 48,
					height: 48,
					borderRadius: 14,
					background: connected ? "#f0f9ff" : "#f8fafc",
					display: "flex",
					alignItems: "center",
					justifyContent: "center",
					fontSize: 20,
					fontWeight: 700,
					color: connected ? "#0284c7" : "#94a3b8",
				}}
			>
				{icon}
			</div>

			<div style={{ flex: 1 }}>
				<div
					style={{ fontWeight: 700, fontSize: 16, color: "#1e293b" }}
				>
					{name}
				</div>
				<div
					style={{
						fontSize: 13,
						color: connected ? "#10b981" : "#64748b",
						display: "flex",
						alignItems: "center",
						gap: 4,
					}}
				>
					{connected ? (
						<FiCheckCircle size={12} />
					) : (
						<FiXCircle size={12} />
					)}
					{connected ? "Connected" : "Not connected"}
				</div>
			</div>

			{connected ? (
				<button
					onClick={handleSync}
					style={{
						background: "#f1f5f9",
						border: "none",
						width: 40,
						height: 40,
						borderRadius: 12,
						display: "flex",
						alignItems: "center",
						justifyContent: "center",
						cursor: "pointer",
						color: "#475569",
					}}
				>
					<FiRefreshCw
						className={syncing ? "spin-anim" : ""}
						style={{ transition: "transform 0.5s" }}
					/>
				</button>
			) : (
				<button
					style={{
						background: "#1e293b",
						color: "white",
						border: "none",
						padding: "8px 16px",
						borderRadius: 10,
						fontWeight: 600,
						fontSize: 13,
						cursor: "pointer",
					}}
				>
					Connect
				</button>
			)}
		</div>
	);
};

export default function SettingsDevices({ onBack }) {
	return (
		<div className="sub-page-container">
			<style>{`
        .spin-anim { animation: spin 1s infinite linear; color: #3b82f6; }
        @keyframes spin { 100% { transform: rotate(360deg); } }
      `}</style>

			<header className="sub-header">
				<button className="back-btn" onClick={onBack}>
					<FiChevronLeft size={24} />
				</button>
				<h2 className="sub-title">Connected Devices</h2>
			</header>

			<div className="sub-content">
				<p
					style={{
						fontSize: 14,
						color: "#64748b",
						marginBottom: 24,
						lineHeight: 1.5,
					}}
				>
					Connect your health apps to automatically sync steps,
					workouts, and nutrition data.
				</p>

				<DeviceItem name="Apple Health" icon="" connected={true} />
				<DeviceItem name="Google Fit" icon="G" connected={false} />
				<DeviceItem name="Oura Ring" icon="O" connected={true} />
				<DeviceItem name="Fitbit" icon="F" connected={false} />
			</div>
		</div>
	);
}
