import React from "react";
import { FiTrendingUp, FiArrowUpRight, FiArrowDownRight } from "react-icons/fi";

const chartData = [40, 65, 50, 80, 55, 90, 75]; // Mock points

export default function Analytics() {
	return (
		<div className="analytics-root">
			<div className="analytics-header">
				<h1>Analytics</h1>
				<div className="range-picker">Last 7 Days ▾</div>
			</div>

			<div className="analytics-scroll">
				{/* Main Score Card */}
				<div className="card score-trend">
					<div className="score-val">
						88{" "}
						<span className="trend up">
							+2.4% <FiArrowUpRight />
						</span>
					</div>
					<div className="score-label">Average Asklepios Score</div>

					{/* Simple CSS Bar Chart Simulation */}
					<div className="chart-area">
						{chartData.map((h, i) => (
							<div key={i} className="chart-col">
								<div
									className="bar"
									style={{ height: `${h}%` }}
								></div>
								<div className="lbl">D{i + 1}</div>
							</div>
						))}
					</div>
				</div>

				{/* Breakdown Grid */}
				<div className="stats-grid">
					<div className="card stat-card">
						<div className="stat-head">Calories</div>
						<div className="stat-val">2,150</div>
						<div className="stat-sub">avg / day</div>
					</div>
					<div className="card stat-card">
						<div className="stat-head">Protein</div>
						<div className="stat-val">142g</div>
						<div className="stat-sub">avg / day</div>
					</div>
					<div className="card stat-card">
						<div className="stat-head">Sleep</div>
						<div className="stat-val">7h 12m</div>
						<div className="stat-sub">avg / night</div>
					</div>
					<div className="card stat-card">
						<div className="stat-head">Weight</div>
						<div className="stat-val">74.5</div>
						<div className="stat-sub">kg (-0.5)</div>
					</div>
				</div>

				<div className="card insight-card">
					<h3>💡 Weekly Insight</h3>
					<p>
						Your recovery score improved by 12% on days when you
						consumed Magnesium-rich foods for lunch.
					</p>
				</div>
			</div>

			<style>{`
				.analytics-root {
					height: 100vh;
					background: #f8fafc;
					display: flex;
					flex-direction: column;
				}
				.analytics-header {
					padding: 24px 20px 16px;
					display: flex;
					justify-content: space-between;
					align-items: center;
				}
				.analytics-header h1 {
					margin: 0; font-size: 24px; color: #0f172a;
				}
				.range-picker {
					font-size: 13px; font-weight: 600; color: #3b82f6; 
					background: #eff6ff; padding: 6px 12px; border-radius: 20px;
				}
				
				.analytics-scroll {
					flex: 1;
					overflow-y: auto;
					padding: 0 20px 100px;
				}
				
				.card {
					background: white; border-radius: 20px; padding: 20px;
					box-shadow: 0 4px 15px rgba(0,0,0,0.02);
					margin-bottom: 16px;
					border: 1px solid #f1f5f9;
				}
				
				.score-trend .score-val {
					font-size: 42px; font-weight: 800; color: #0f172a;
					display: flex; align-items: baseline; gap: 12px;
				}
				.trend {
					font-size: 14px; font-weight: 700; padding: 4px 8px; border-radius: 8px;
					display: flex; align-items: center; gap: 4px;
				}
				.trend.up { background: #ecfdf5; color: #10b981; }
				.score-label { color: #64748b; font-size: 13px; font-weight: 600; margin-bottom: 24px; }
				
				.chart-area {
					height: 120px;
					display: flex;
					align-items: flex-end;
					justify-content: space-between;
					gap: 8px;
				}
				.chart-col {
					flex: 1;
					display: flex;
					flex-direction: column;
					align-items: center;
					gap: 6px;
					height: 100%;
					justify-content: flex-end;
				}
				.chart-col .bar {
					width: 100%;
					max-width: 24px;
					background: #e2e8f0;
					border-radius: 6px;
					transition: height 0.5s ease;
				}
				.chart-col:last-child .bar { background: #3b82f6; }
				.chart-col .lbl {
					font-size: 10px; color: #94a3b8; font-weight: 600;
				}

				.stats-grid {
					display: grid;
					grid-template-columns: 1fr 1fr;
					gap: 16px;
					margin-bottom: 16px;
				}
				.stat-card { margin: 0; padding: 16px; }
				.stat-head { font-size: 12px; color: #64748b; font-weight: 600; margin-bottom: 4px; }
				.stat-val { font-size: 24px; font-weight: 800; color: #0f172a; }
				.stat-sub { font-size: 11px; color: #94a3b8; }

				.insight-card {
					background: linear-gradient(135deg, #eff6ff 0%, #ffffff 100%);
					border-left: 4px solid #3b82f6;
				}
				.insight-card h3 { margin: 0 0 8px; font-size: 15px; color: #1e40af; }
				.insight-card p { margin: 0; font-size: 13px; color: #334155; line-height: 1.5; }
			`}</style>
		</div>
	);
}
