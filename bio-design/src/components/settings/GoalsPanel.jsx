import React from "react";
import SlidePanel from "./SlidePanel";
import "./settings.css";

export default function GoalsPanel({ open, onClose }) {
	const [goals, setGoals] = React.useState({
		cals: 2150,
		protein: 140,
		carbs: 250,
		fat: 70,
	});
	function update(k, v) {
		setGoals((g) => ({ ...g, [k]: v }));
	}
	function save() {
		setTimeout(() => onClose(), 300);
	}

	return (
		<SlidePanel
			open={open}
			title="Nutritional Goals"
			onClose={onClose}
			footer={
				<>
					<button className="btn" onClick={onClose}>
						Cancel
					</button>
					<button className="btn primary" onClick={save}>
						Save
					</button>
				</>
			}
		>
			<div>
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
			</div>
		</SlidePanel>
	);
}
