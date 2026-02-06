import React from "react";
import { FiRefreshCw, FiActivity, FiCpu, FiHeart } from "react-icons/fi";

const mockVitals = [
	{
		label: "Resting HR",
		value: "58",
		unit: "bpm",
		icon: <FiHeart />,
		color: "#ef4444",
	},
	{
		label: "HRV (SDNN)",
		value: "42",
		unit: "ms",
		icon: <FiActivity />,
		color: "#8b5cf6",
	},
	{
		label: "Stress",
		value: "Low",
		unit: "12%",
		icon: <FiCpu />,
		color: "#10b981",
	},
];

export default function LiveVitals() {
	const [loading, setLoading] = React.useState(false);

	const handleRefresh = () => {
		setLoading(true);
		// Simulate network request
		setTimeout(() => setLoading(false), 1200);
	};

	return (
		<div className="card live-vitals">
			<div className="card-title">
				Live Vitals{" "}
				<button
					className={`refresh ${loading ? "spinning" : ""}`}
					onClick={handleRefresh}
					style={{ transition: "transform 1s ease" }}
				>
					<FiRefreshCw />
				</button>
			</div>

			<div className="vitals-grid">
				{mockVitals.map((item, i) => (
					<div key={i} className="vital-item">
						<div
							className="vital-icon"
							style={{
								color: item.color,
								backgroundColor: `${item.color}15`,
							}}
						>
							{item.icon}
						</div>
						<div className="vital-data">
							<div className="val">
								{item.value}{" "}
								<span className="unit">{item.unit}</span>
							</div>
							<div className="lbl">{item.label}</div>
						</div>
					</div>
				))}
			</div>

			<style>{`
				.vitals-grid {
					display: grid;
					grid-template-columns: repeat(3, 1fr);
					gap: 12px;
				}
				.vital-item {
					display: flex;
					flex-direction: column;
					align-items: center;
					text-align: center;
					padding: 12px 4px;
					border-radius: 12px;
					background: #f8fafc;
				}
				.vital-icon {
					width: 32px;
					height: 32px;
					border-radius: 10px;
					display: flex;
					align-items: center;
					justify-content: center;
					margin-bottom: 8px;
					font-size: 16px;
				}
				.vital-data .val {
					font-weight: 800;
					font-size: 15px;
					color: #0f172a;
				}
				.vital-data .unit {
					font-size: 10px;
					color: #94a3b8;
					font-weight: 600;
				}
				.vital-data .lbl {
					font-size: 10px;
					color: #64748b;
					margin-top: 2px;
					font-weight: 600;
				}
				.spinning {
					transform: rotate(360deg);
				}
			`}</style>
		</div>
	);
}
