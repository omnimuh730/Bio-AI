import React, { useState } from "react";
import "../home.css";
import Dashboard from "./Dashboard";
import Capture from "./Capture";
import Planner from "./Planner";
import Analytics from "./Analytics";
import Settings from "./Settings";
import BottomNav from "./dashboard/BottomNav";

export default function Home() {
	const [tab, setTab] = useState("dashboard");

	return (
		<div className="home-root">
			<div className="home-content">
				{tab === "dashboard" && <Dashboard />}
				{tab === "capture" && (
					<Capture onClose={() => setTab("dashboard")} />
				)}
				{tab === "planner" && <Planner />}
				{tab === "analytics" && <Analytics />}
				{tab === "settings" && <Settings />}
			</div>

			{tab !== "capture" && (
				<BottomNav active={tab} onTabChange={setTab} />
			)}
		</div>
	);
}
