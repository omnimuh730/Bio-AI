import React from "react";
import {
	FiHome,
	FiCamera,
	FiCalendar,
	FiPieChart,
	FiSettings,
	FiPlus,
} from "react-icons/fi";

export default function BottomNav({ active, onTabChange }) {
	return (
		<div className="bottom-nav-container">
			<nav className="floating-nav">
				<button
					className={`nav-item ${active === "dashboard" ? "active" : ""}`}
					onClick={() => onTabChange("dashboard")}
				>
					<FiHome size={22} />
				</button>
				<button
					className={`nav-item ${active === "planner" ? "active" : ""}`}
					onClick={() => onTabChange("planner")}
				>
					<FiCalendar size={22} />
				</button>

				<div className="nav-fab-wrapper">
					<button
						className={`nav-fab ${active === "capture" ? "active-fab" : ""}`}
						onClick={() => onTabChange("capture")}
					>
						{active === "capture" ? (
							<FiCamera size={24} />
						) : (
							<FiPlus size={24} />
						)}
					</button>
				</div>

				<button
					className={`nav-item ${active === "analytics" ? "active" : ""}`}
					onClick={() => onTabChange("analytics")}
				>
					<FiPieChart size={22} />
				</button>
				<button
					className={`nav-item ${active === "settings" ? "active" : ""}`}
					onClick={() => onTabChange("settings")}
				>
					<FiSettings size={22} />
				</button>
			</nav>

			<style>{`
				.active-fab {
					background: #ff7a55 !important;
					transform: scale(1.1);
				}
			`}</style>
		</div>
	);
}
