import React from "react";
import SettingsPageHeader from "./SettingsPageHeader";
import "./settings.css";

const initialDevices = [
	{ id: "scale-01", name: "Smart Scale", model: "AX-200", active: true },
	{ id: "watch-02", name: "Pulse Watch", model: "PulseX", active: true },
	{
		id: "fridge-03",
		name: "Fridge Sensor",
		model: "CoolSense",
		active: false,
	},
];

export default function DevicesPage({ onBack }) {
	const [devices, setDevices] = React.useState(initialDevices);

	function toggle(id) {
		const next = devices.map((d) =>
			d.id === id ? { ...d, active: !d.active } : d,
		);
		setDevices(next);
	}

	return (
		<div className="settings-page enter">
			<SettingsPageHeader
				title="Connected Devices"
				subtitle="2 Active • Manage your hardware"
				onBack={onBack}
			/>
			<div className="settings-page-content">
				<div style={{ color: "#64748b", marginBottom: 16 }}>
					Manage your connected hardware. Toggle to activate or
					deactivate. These are mock devices for demo flows.
				</div>
				<div
					style={{
						display: "flex",
						flexDirection: "column",
						gap: 12,
					}}
				>
					{devices.map((dev) => (
						<div
							key={dev.id}
							className="setting-item"
							style={{ justifyContent: "space-between" }}
						>
							<div
								style={{
									display: "flex",
									gap: 12,
									alignItems: "center",
								}}
							>
								<div className="setting-icon">🔌</div>
								<div>
									<div style={{ fontWeight: 700 }}>
										{dev.name}
									</div>
									<div
										style={{
											fontSize: 12,
											color: "#64748b",
										}}
									>
										{dev.model}
									</div>
								</div>
							</div>
							<div
								style={{
									display: "flex",
									alignItems: "center",
									gap: 8,
								}}
							>
								<div
									className={`switch ${dev.active ? "on" : ""}`}
									onClick={() => toggle(dev.id)}
									role="switch"
									aria-checked={dev.active}
								>
									<div className="knob" />
								</div>
								<div
									style={{
										fontSize: 12,
										color: dev.active
											? "#16a34a"
											: "#94a3b8",
									}}
								>
									{dev.active ? "Active" : "Inactive"}
								</div>
							</div>
						</div>
					))}
				</div>

				<div className="settings-page-actions">
					<button className="btn primary" onClick={onBack}>
						Done
					</button>
				</div>
			</div>
		</div>
	);
}
