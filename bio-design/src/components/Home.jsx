import React, { useState } from "react";
import "../home.css";
import Dashboard from "./Dashboard";
import Capture from "./Capture";
import Planner from "./Planner";
import Analytics from "./Analytics";
import Settings from "./Settings";
import ProfilePage from "./settings/ProfilePage";
import DevicesPage from "./settings/DevicesPage";
import PreferencesPage from "./settings/PreferencesPage";
import GoalsPage from "./settings/GoalsPage";
import HelpPage from "./settings/HelpPage";
import BottomNav from "./dashboard/BottomNav";

export default function Home() {
	const [tab, setTab] = useState("dashboard");

	function handleSettingsNavigation(page) {
		setTab(page);
	}

	function handleBackFromSettingsPage() {
		setTab("settings");
	}

	return (
		<div className="home-root">
			<div className="home-content">
				{tab === "dashboard" && <Dashboard />}
				{tab === "capture" && (
					<Capture onClose={() => setTab("dashboard")} />
				)}
				{tab === "planner" && <Planner />}
				{tab === "analytics" && <Analytics />}
				{tab === "settings" && (
					<Settings onNavigate={handleSettingsNavigation} />
				)}
				{tab === "settings-profile" && (
					<ProfilePage onBack={handleBackFromSettingsPage} />
				)}
				{tab === "settings-devices" && (
					<DevicesPage onBack={handleBackFromSettingsPage} />
				)}
				{tab === "settings-preferences" && (
					<PreferencesPage onBack={handleBackFromSettingsPage} />
				)}
				{tab === "settings-goals" && (
					<GoalsPage onBack={handleBackFromSettingsPage} />
				)}
				{tab === "settings-help" && (
					<HelpPage onBack={handleBackFromSettingsPage} />
				)}
			</div>

			{!tab.startsWith("settings-") && tab !== "capture" && (
				<BottomNav active={tab} onTabChange={setTab} />
			)}
		</div>
	);
}
