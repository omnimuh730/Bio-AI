import React from "react";
import SlidePanel from "./SlidePanel";
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

export default function DevicesPanel({ open, onClose, onUpdateBadge }) {
	const [devices, setDevices] = React.useState(initialDevices);

	React.useEffect(() => {
		if (onUpdateBadge)
			onUpdateBadge(devices.filter((d) => d.active).length);
	}, []);

	function toggle(id) {
		const next = devices.map((d) =>
			d.id === id ? { ...d, active: !d.active } : d,
		);
		setDevices(next);
		if (onUpdateBadge) onUpdateBadge(next.filter((d) => d.active).length);
	}

	return (
		<SlidePanel
			open={open}
			title="Connected Devices"
			onClose={onClose}
			footer={
				<button
					className="btn primary"
					onClick={() => {
						onClose();
					}}
				>
					Done
				</button>
			}
		>
			<div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
				<div style={{ color: "#64748b" }}>
					Manage your connected hardware. Toggle to activate or
					deactivate. These are mock devices for demo flows.
				</div>
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
								<div style={{ fontSize: 12, color: "#64748b" }}>
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
									color: dev.active ? "#16a34a" : "#94a3b8",
								}}
							>
								{dev.active ? "Active" : "Inactive"}
							</div>
						</div>
					</div>
				))}
			</div>
		</SlidePanel>
	);
}
