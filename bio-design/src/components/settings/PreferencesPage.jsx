import React from "react";
import SettingsPageHeader from "./SettingsPageHeader";
import "./settings.css";

export default function PreferencesPage({ onBack }) {
	const [state, setState] = React.useState({
		mealReminders: true,
		darkMode: false,
		autoLog: false,
	});

	function toggle(key) {
		setState((s) => ({ ...s, [key]: !s[key] }));
	}

	return (
		<div className="settings-page enter">
			<SettingsPageHeader
				title="Preferences"
				subtitle="App, notifications, privacy"
				onBack={onBack}
			/>
			<div className="settings-page-content">
				<div className="form-row">
					<label>Meal Reminders</label>
					<div
						style={{
							display: "flex",
							alignItems: "center",
							gap: 12,
						}}
					>
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
					<div
						style={{
							display: "flex",
							alignItems: "center",
							gap: 12,
						}}
					>
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
					<div
						style={{
							display: "flex",
							alignItems: "center",
							gap: 12,
						}}
					>
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

				<div className="settings-page-actions">
					<button className="btn" onClick={onBack}>
						Cancel
					</button>
					<button
						className="btn primary"
						onClick={() => {
							setTimeout(() => onBack(), 200);
						}}
					>
						Save
					</button>
				</div>
			</div>
		</div>
	);
}
