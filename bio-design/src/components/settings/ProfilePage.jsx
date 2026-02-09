import React from "react";
import SettingsPageHeader from "./SettingsPageHeader";
import "./settings.css";

export default function ProfilePage({ onBack }) {
	const [form, setForm] = React.useState({
		name: "Dekomori",
		membership: "Premium Member",
		weight: 68,
		height: 172,
	});
	const [saved, setSaved] = React.useState(false);

	function onSave() {
		setSaved(true);
		setTimeout(() => setSaved(false), 900);
	}

	return (
		<div className="settings-page enter">
			<SettingsPageHeader
				title="Profile & Body Stats"
				subtitle="Edit name, weight, height"
				onBack={onBack}
			/>
			<div className="settings-page-content">
				<div className="form-row">
					<label>Full Name</label>
					<input
						className="input"
						value={form.name}
						onChange={(e) =>
							setForm({ ...form, name: e.target.value })
						}
					/>
				</div>
				<div className="form-row">
					<label>Membership</label>
					<div className="badge">{form.membership}</div>
				</div>
				<div style={{ display: "flex", gap: 12 }}>
					<div style={{ flex: 1 }} className="form-row">
						<label>Weight (kg)</label>
						<input
							className="input"
							type="number"
							value={form.weight}
							onChange={(e) =>
								setForm({ ...form, weight: +e.target.value })
							}
						/>
					</div>
					<div style={{ width: 12 }} />
					<div style={{ flex: 1 }} className="form-row">
						<label>Height (cm)</label>
						<input
							className="input"
							type="number"
							value={form.height}
							onChange={(e) =>
								setForm({ ...form, height: +e.target.value })
							}
						/>
					</div>
				</div>

				<div className="settings-page-actions">
					<button className="btn" onClick={onBack}>
						Cancel
					</button>
					<button
						className={`btn primary ${saved ? "save-anim" : ""}`}
						onClick={onSave}
					>
						Save
					</button>
				</div>
			</div>
		</div>
	);
}
