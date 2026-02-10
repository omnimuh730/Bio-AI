import React, { useState } from "react";
import "./home.css";
import Dashboard from "./dashboard";
import Capture from "./capture";
import Planner from "./planner";
import Analytics from "./analytics";
import Settings from "./settings";
import ProfilePage from "./settings/components/ProfilePage";
import DevicesPage from "./settings/components/DevicesPage";
import PreferencesPage from "./settings/components/PreferencesPage";
import GoalsPage from "./settings/components/GoalsPage";
import HelpPage from "./settings/components/HelpPage";
import RecommendedFoods from "./dashboard/components/RecommendedFoods";
import BottomNav from "./utils/BottomNav";

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
				{tab === "dashboard" && (
					<Dashboard
						onNavigate={(page) => {
							console.log("Navigating to", page);
							setTab(page);
						}}
					/>
				)}
				{tab === "recommended" && (
					<RecommendedFoods onBack={() => setTab("dashboard")} />
				)}
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

			{!tab.startsWith("settings-") &&
				tab !== "capture" &&
				tab !== "recommended" && (
					<BottomNav active={tab} onTabChange={setTab} />
				)}
		</div>
	);
}
