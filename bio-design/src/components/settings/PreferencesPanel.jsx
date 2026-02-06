import React from "react";
import SlidePanel from "./SlidePanel";
import "./settings.css";

export default function PreferencesPanel({ open, onClose, initial }) {
	const [state, setState] = React.useState({
		mealReminders: true,
		darkMode: false,
		autoLog: false,
		...initial,
	});

	function toggle(key) {
		setState((s) => ({ ...s, [key]: !s[key] }));
	}

	return (
		<SlidePanel
			open={open}
			title="Preferences"
			onClose={onClose}
			footer={
				<>
					<button className="btn" onClick={onClose}>
						Cancel
					</button>
					<button
						className="btn primary save-anim"
						onClick={() => {
							setTimeout(() => onClose(), 220);
						}}
					>
						Save
					</button>
				</>
			}
		>
			<div className="form-row">
				<label>Meal Reminders</label>
				<div style={{ display: "flex", alignItems: "center", gap: 12 }}>
					<div
						className={`switch ${state.mealReminders ? "on" : ""}`}
						onClick={() => toggle("mealReminders")}
					>
						<div className="knob" />
					</div>
					<div className="setting-sub">
						Receive reminders for planned meals
					</div>
				</div>
			</div>
			<div className="form-row">
				<label>Dark Mode</label>
				<div style={{ display: "flex", alignItems: "center", gap: 12 }}>
					<div
						className={`switch ${state.darkMode ? "on" : ""}`}
						onClick={() => toggle("darkMode")}
					>
						<div className="knob" />
					</div>
					<div className="setting-sub">
						Enable app dark theme (mock)
					</div>
				</div>
			</div>
			<div className="form-row">
				<label>Auto Log Meals</label>
				<div style={{ display: "flex", alignItems: "center", gap: 12 }}>
					<div
						className={`switch ${state.autoLog ? "on" : ""}`}
						onClick={() => toggle("autoLog")}
					>
						<div className="knob" />
					</div>
					<div className="setting-sub">
						Try to auto-detect and log meals
					</div>
				</div>
			</div>
		</SlidePanel>
	);
}
