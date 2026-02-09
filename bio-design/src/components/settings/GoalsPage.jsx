import React from "react";
import SettingsPageHeader from "./SettingsPageHeader";
import "./settings.css";

export default function GoalsPage({ onBack }) {
	const [goals, setGoals] = React.useState({
		cals: 2150,
		protein: 140,
		carbs: 250,
		fat: 70,
	});

	function update(k, v) {
		setGoals((g) => ({ ...g, [k]: v }));
	}

	return (
		<div className="settings-page enter">
			<SettingsPageHeader
				title="Nutritional Goals"
				subtitle="Set calorie & macros targets"
				onBack={onBack}
			/>
			<div className="settings-page-content">
				<div className="form-row">
					<label>Calories target</label>
					<input
						className="input"
						type="number"
						value={goals.cals}
						onChange={(e) => update("cals", +e.target.value)}
					/>
				</div>
				<div className="form-row">
					<label>Protein (g)</label>
					<input
						className="input"
						type="number"
						value={goals.protein}
						onChange={(e) => update("protein", +e.target.value)}
					/>
				</div>
				<div className="form-row">
					<label>Carbs (g)</label>
					<input
						className="input"
						type="number"
						value={goals.carbs}
						onChange={(e) => update("carbs", +e.target.value)}
					/>
				</div>
				<div className="form-row">
					<label>Fat (g)</label>
					<input
						className="input"
						type="number"
						value={goals.fat}
						onChange={(e) => update("fat", +e.target.value)}
					/>
				</div>

				<div className="settings-page-actions">
					<button className="btn" onClick={onBack}>
						Cancel
					</button>
					<button
						className="btn primary"
						onClick={() => setTimeout(() => onBack(), 300)}
					>
						Save
					</button>
				</div>
			</div>
		</div>
	);
}
