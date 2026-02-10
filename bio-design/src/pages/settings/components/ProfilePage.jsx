import React, { useState } from "react";
import { FiChevronLeft, FiCamera, FiCheck } from "react-icons/fi";

export default function SettingsProfile({ onBack }) {
	const [loading, setLoading] = useState(false);

	const handleSave = () => {
		setLoading(true);
		setTimeout(() => {
			setLoading(false);
			onBack();
		}, 1500);
	};

	return (
		<div className="sub-page-container">
			<header className="sub-header">
				<button className="back-btn" onClick={onBack}>
					<FiChevronLeft size={24} />
				</button>
				<h2 className="sub-title">Edit Profile</h2>
			</header>

			<div className="sub-content">
				{/* Avatar Editor */}
				<div
					style={{
						display: "flex",
						justifyContent: "center",
						marginBottom: 32,
					}}
				>
					<div style={{ position: "relative" }}>
						<div
							style={{
								width: 100,
								height: 100,
								borderRadius: 30,
								background:
									"linear-gradient(135deg, #3b82f6, #06b6d4)",
								display: "flex",
								alignItems: "center",
								justifyContent: "center",
								fontSize: 32,
								fontWeight: 700,
								color: "white",
								boxShadow:
									"0 10px 25px rgba(59, 130, 246, 0.3)",
							}}
						>
							DE
						</div>
						<button
							style={{
								position: "absolute",
								bottom: -6,
								right: -6,
								width: 36,
								height: 36,
								borderRadius: "50%",
								background: "#fff",
								border: "none",
								boxShadow: "0 4px 10px rgba(0,0,0,0.1)",
								display: "flex",
								alignItems: "center",
								justifyContent: "center",
								cursor: "pointer",
								color: "#333",
							}}
						>
							<FiCamera size={18} />
						</button>
					</div>
				</div>

				<div className="form-card">
					<div className="input-group">
						<label className="input-label">Full Name</label>
						<input
							className="lux-input"
							type="text"
							defaultValue="Dekomori Sanae"
						/>
					</div>

					<div style={{ display: "flex", gap: 16 }}>
						<div className="input-group" style={{ flex: 1 }}>
							<label className="input-label">Weight (kg)</label>
							<input
								className="lux-input"
								type="number"
								defaultValue="54"
							/>
						</div>
						<div className="input-group" style={{ flex: 1 }}>
							<label className="input-label">Height (cm)</label>
							<input
								className="lux-input"
								type="number"
								defaultValue="165"
							/>
						</div>
					</div>

					<div className="input-group">
						<label className="input-label">Email</label>
						<input
							className="lux-input"
							type="email"
							defaultValue="admin@bioai.com"
							disabled
							style={{ opacity: 0.6 }}
						/>
					</div>
				</div>

				<button
					className={`save-btn ${loading ? "loading" : ""}`}
					onClick={handleSave}
				>
					{loading ? "Saving Changes..." : "Save Profile"}
				</button>
			</div>
		</div>
	);
}
