import React, { useState } from "react";
import { FiChevronLeft } from "react-icons/fi";

export default function SettingsGoals({ onBack }) {
	const [cals, setCals] = useState(2200);
	const [protein, setProtein] = useState(140);

	return (
		<div className="sub-page-container">
			<style>{`
        .glass-range {
          -webkit-appearance: none; width: 100%; height: 8px;
          border-radius: 10px; background: rgba(0,0,0,0.05); outline: none;
        }
        .glass-range::-webkit-slider-thumb {
          -webkit-appearance: none; appearance: none;
          width: 28px; height: 28px; border-radius: 50%;
          background: #fff;
          box-shadow: 0 4px 10px rgba(0,0,0,0.15), 0 0 0 4px rgba(255,255,255,0.4);
          cursor: pointer; transition: transform 0.1s;
        }
        .glass-range::-webkit-slider-thumb:active { transform: scale(1.1); }
      `}</style>

			<header className="sub-header">
				<button className="back-btn" onClick={onBack}>
					<FiChevronLeft size={24} />
				</button>
				<h2 className="sub-title">Nutritional Goals</h2>
			</header>

			<div className="sub-content">
				{/* Main Calorie Card */}
				<div
					className="form-card"
					style={{
						background: "linear-gradient(135deg, #f97316, #ea580c)",
						color: "white",
					}}
				>
					<div style={{ textAlign: "center", marginBottom: 20 }}>
						<div
							style={{
								fontSize: 13,
								opacity: 0.9,
								fontWeight: 600,
							}}
						>
							DAILY TARGET
						</div>
						<div
							style={{
								fontSize: 48,
								fontWeight: 800,
								letterSpacing: "-1px",
							}}
						>
							{cals}{" "}
							<span style={{ fontSize: 16, fontWeight: 600 }}>
								kcal
							</span>
						</div>
					</div>
					<input
						type="range"
						min="1200"
						max="4000"
						step="50"
						value={cals}
						onChange={(e) => setCals(e.target.value)}
						className="glass-range"
						style={{ accentColor: "white" }} // Fallback
					/>
				</div>

				<h3
					className="input-label"
					style={{ marginLeft: 8, marginTop: 24 }}
				>
					Macro Split
				</h3>

				<div className="form-card">
					<div className="input-group">
						<div
							style={{
								display: "flex",
								justifyContent: "space-between",
								marginBottom: 12,
							}}
						>
							<span style={{ fontWeight: 600, color: "#334155" }}>
								Protein
							</span>
							<span style={{ fontWeight: 700, color: "#3b82f6" }}>
								{protein}g
							</span>
						</div>
						<input
							type="range"
							className="glass-range"
							min="50"
							max="300"
							value={protein}
							onChange={(e) => setProtein(e.target.value)}
							style={{
								background:
									"linear-gradient(to right, #3b82f6 0%, #e2e8f0 0%)",
							}}
						/>
					</div>

					<div className="input-group">
						<div
							style={{
								display: "flex",
								justifyContent: "space-between",
								marginBottom: 12,
							}}
						>
							<span style={{ fontWeight: 600, color: "#334155" }}>
								Carbs
							</span>
							<span style={{ fontWeight: 700, color: "#10b981" }}>
								220g
							</span>
						</div>
						<input
							type="range"
							className="glass-range"
							defaultValue="220"
						/>
					</div>

					<div className="input-group" style={{ marginBottom: 0 }}>
						<div
							style={{
								display: "flex",
								justifyContent: "space-between",
								marginBottom: 12,
							}}
						>
							<span style={{ fontWeight: 600, color: "#334155" }}>
								Fats
							</span>
							<span style={{ fontWeight: 700, color: "#f59e0b" }}>
								65g
							</span>
						</div>
						<input
							type="range"
							className="glass-range"
							defaultValue="65"
						/>
					</div>
				</div>
			</div>
		</div>
	);
}
