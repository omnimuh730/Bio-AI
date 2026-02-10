import React from "react";
import { FiChevronLeft, FiChevronRight, FiCheck } from "react-icons/fi";

const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const dates = [4, 5, 6, 7, 8, 9, 10]; // Mock dates around Feb 5

export default function Planner() {
	const [activeDate, setActiveDate] = React.useState(5); // Feb 5

	return (
		<div className="planner-root">
			{/* Calendar Strip */}
			<div className="planner-header">
				<div className="month-row">
					<h2>February 2026</h2>
					<div className="week-toggle">Week ▾</div>
				</div>
				<div className="days-strip">
					{dates.map((d, i) => (
						<div
							key={d}
							className={`day-item ${d === activeDate ? "active" : ""}`}
							onClick={() => setActiveDate(d)}
						>
							<div className="d-name">{days[i]}</div>
							<div className="d-num">{d}</div>
							{d === 5 && <div className="dot"></div>}
						</div>
					))}
				</div>
			</div>

			<div className="planner-scroll">
				{/* AI Meal Plan Card */}
				<div className="section-title">Today's Plan</div>

				<div className="meal-card breakfast">
					<div className="meal-time">
						BREAKFAST • 08:00 AM <FiCheck className="check" />
					</div>
					<div className="meal-content">
						<div className="meal-info">
							<h3>Oatmeal & Berries</h3>
							<p>320 kcal • 12g Protein</p>
						</div>
						<img
							src="https://images.unsplash.com/photo-1517673132405-a56a62b18caf?auto=format&fit=crop&w=120&q=80"
							alt="oats"
						/>
					</div>
				</div>

				<div className="meal-card lunch active-meal">
					<div className="status-stripe"></div>
					<div className="meal-time">LUNCH • 12:30 PM</div>
					<div className="meal-content">
						<div className="meal-info">
							<h3>Magnesium Power Bowl</h3>
							<p>450 kcal • 22g Protein</p>
							<div className="tags">
								<span className="tag">High Volume</span>
								<span className="tag">Anti-Stress</span>
							</div>
						</div>
						<img
							src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=120&q=80"
							alt="bowl"
						/>
					</div>
					<div className="meal-actions">
						<button className="btn-sec">Swap</button>
						<button className="btn-pri">Log This</button>
					</div>
				</div>

				<div className="meal-card dinner">
					<div className="meal-time">DINNER • 07:00 PM</div>
					<div className="meal-content">
						<div className="meal-info">
							<h3>Grilled Salmon & Asparagus</h3>
							<p>520 kcal • 45g Protein</p>
						</div>
						<img
							src="https://images.unsplash.com/photo-1467003909585-2f8a7270028d?auto=format&fit=crop&w=120&q=80"
							alt="salmon"
						/>
					</div>
				</div>

				<div className="section-title">Shopping List</div>
				<div className="shopping-preview">
					<div className="shop-item">
						<div className="cb"></div>
						<span>Salmon Fillet (200g)</span>
					</div>
					<div className="shop-item">
						<div className="cb"></div>
						<span>Asparagus Bundle</span>
					</div>
					<div className="shop-more">+ 4 more items</div>
				</div>
			</div>

			<style>{`
				.planner-root {
					height: 100vh;
					background: #f8fafc;
					display: flex;
					flex-direction: column;
				}
				.planner-header {
					background: white;
					padding: 20px 0 16px;
					box-shadow: 0 4px 12px rgba(0,0,0,0.02);
					z-index: 10;
				}
				.month-row {
					padding: 0 20px 16px;
					display: flex;
					justify-content: space-between;
					align-items: center;
				}
				.month-row h2 {
					margin: 0;
					font-size: 18px;
					font-weight: 800;
					color: #0f172a;
				}
				.week-toggle {
					font-size: 12px;
					font-weight: 600;
					color: #64748b;
					background: #f1f5f9;
					padding: 6px 10px;
					border-radius: 8px;
				}
				.days-strip {
					display: flex;
					justify-content: space-between;
					padding: 0 12px;
				}
				.day-item {
					display: flex;
					flex-direction: column;
					align-items: center;
					gap: 6px;
					padding: 10px 8px;
					border-radius: 14px;
					min-width: 44px;
					cursor: pointer;
					position: relative;
				}
				.day-item.active {
					background: #3b82f6;
					color: white;
					box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
				}
				.d-name { font-size: 10px; font-weight: 600; opacity: 0.7; }
				.d-num { font-size: 16px; font-weight: 700; }
				.dot {
					width: 4px; height: 4px; background: white; border-radius: 50%;
					position: absolute; bottom: 6px;
				}
				
				.planner-scroll {
					flex: 1;
					overflow-y: auto;
					padding: 20px 20px 100px;
				}
				.section-title {
					font-size: 15px;
					font-weight: 700;
					color: #334155;
					margin: 8px 0 12px;
				}
				
				.meal-card {
					background: white;
					border-radius: 16px;
					padding: 16px;
					margin-bottom: 16px;
					border: 1px solid #f1f5f9;
					position: relative;
					overflow: hidden;
				}
				.meal-card.breakfast { opacity: 0.7; }
				.meal-card.active-meal {
					border-color: #3b82f6;
					box-shadow: 0 8px 24px rgba(59, 130, 246, 0.08);
				}
				.status-stripe {
					position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: #3b82f6;
				}
				.meal-time {
					font-size: 11px;
					color: #94a3b8;
					font-weight: 700;
					margin-bottom: 12px;
					display: flex; align-items: center; gap: 6px;
				}
				.check { color: #10b981; }
				
				.meal-content {
					display: flex;
					justify-content: space-between;
					align-items: center;
				}
				.meal-info h3 {
					margin: 0 0 4px;
					font-size: 16px;
					font-weight: 700;
					color: #0f172a;
				}
				.meal-info p {
					margin: 0;
					font-size: 13px;
					color: #64748b;
				}
				.meal-content img {
					width: 64px; height: 64px; border-radius: 12px; object-fit: cover;
				}
				.tags { display: flex; gap: 6px; margin-top: 8px; }
				.tag {
					font-size: 10px; font-weight: 600; padding: 4px 8px;
					border-radius: 6px; background: #eff6ff; color: #3b82f6;
				}
				
				.meal-actions {
					margin-top: 16px;
					display: flex; gap: 12px;
				}
				.btn-pri {
					flex: 1; padding: 10px; background: #0f172a; color: white;
					border: none; border-radius: 10px; font-weight: 600; font-size: 13px;
				}
				.btn-sec {
					padding: 10px 16px; background: #f1f5f9; color: #475569;
					border: none; border-radius: 10px; font-weight: 600; font-size: 13px;
				}

				.shopping-preview {
					background: white;
					border-radius: 16px;
					padding: 16px;
				}
				.shop-item {
					display: flex; align-items: center; gap: 12px;
					padding: 8px 0;
					border-bottom: 1px solid #f8fafc;
				}
				.cb {
					width: 20px; height: 24px; border: 2px solid #cbd5e1; border-radius: 6px;
				}
				.shop-item span {
					font-size: 14px; color: #334155; font-weight: 500;
				}
				.shop-more {
					text-align: center; color: #94a3b8; font-size: 12px; font-weight: 600; margin-top: 12px;
				}
			`}</style>
		</div>
	);
}
