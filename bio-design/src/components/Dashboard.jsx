import React from "react";
import "./dashboard.css";
import Header from "./dashboard/Header";
import AISuggestion from "./dashboard/AISuggestion";
import DailyFuel from "./dashboard/DailyFuel";
import Hydration from "./dashboard/Hydration";
import QuickLog from "./dashboard/QuickLog";
import BottomNav from "./dashboard/BottomNav";

export default function Dashboard() {
	return (
		<div className="dashboard-root">
			<Header />
			<div className="dashboard-scroll">
				<AISuggestion />
				<DailyFuel />
				<Hydration />
				<QuickLog />
			</div>
			<BottomNav />
		</div>
	);
}
