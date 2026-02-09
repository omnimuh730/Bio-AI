import React, { useState } from "react";
import {
	FiChevronRight,
	FiLogOut,
	FiUser,
	FiTarget,
	FiSettings,
	FiSmartphone,
	FiHelpCircle,
	FiMoon,
	FiBell,
} from "react-icons/fi";
import "./styles/settings.css";
import LogoutModal from "./components/LogoutModal";

const SettingItem = ({
	icon: Icon,
	color,
	title,
	sub,
	badge,
	onClick,
	isDestructive,
}) => (
	<div
		className={`setting-item interactive ${isDestructive ? "destructive" : ""}`}
		onClick={onClick}
	>
		<div
			className="setting-icon-box"
			style={{
				background: isDestructive ? "rgba(239, 68, 68, 0.1)" : color,
			}}
		>
			<Icon
				className="icon-svg"
				style={{ color: isDestructive ? "#ef4444" : "#fff" }}
			/>
		</div>
		<div className="setting-info">
			<div className="setting-title">{title}</div>
			{sub && <div className="setting-sub">{sub}</div>}
		</div>
		<div className="setting-action">
			{badge && <span className="setting-badge">{badge}</span>}
			<FiChevronRight className="chevron" />
		</div>
	</div>
);

export default function Settings({ onNavigate }) {
	const [devicesActiveCount] = useState(2);
	const [toast, setToast] = useState(null);
	const [logoutOpen, setLogoutOpen] = useState(false);

	function showToast(msg) {
		setToast(msg);
		setTimeout(() => setToast(null), 2000);
	}

	return (
		<div className="settings-root">
			{/* Animated Background Elements */}
			<div className="bg-blob blob-1" />
			<div className="bg-blob blob-2" />

			<div className="settings-container">
				<header className="page-header">
					<h1>Settings</h1>
				</header>

				<div className="scroll-content">
					{/* Premium Profile Card */}
					<div
						className="profile-card interactive"
						onClick={() => onNavigate("settings-profile")}
					>
						<div className="profile-glass-layer">
							<div className="profile-row">
								<div className="avatar">DE</div>
								<div className="profile-details">
									<div className="name">Dekomori</div>
									<div className="membership">
										<span className="star-icon">★</span>{" "}
										Premium Member
									</div>
								</div>
								<div className="edit-btn">Edit</div>
							</div>
							<div className="profile-stats">
								<div className="stat">
									<span className="val">12</span>
									<span className="lbl">Streak</span>
								</div>
								<div className="stat">
									<span className="val">Daily</span>
									<span className="lbl">Plan</span>
								</div>
								<div className="stat">
									<span className="val">85%</span>
									<span className="lbl">Goal</span>
								</div>
							</div>
						</div>
					</div>

					{/* Section: Account */}
					<div className="section-label">Account</div>
					<div className="settings-group">
						<SettingItem
							icon={FiUser}
							color="linear-gradient(135deg, #3b82f6, #2563eb)"
							title="Personal Data"
							sub="Name, weight, height"
							onClick={() => onNavigate("settings-profile")}
						/>
						<SettingItem
							icon={FiTarget}
							color="linear-gradient(135deg, #f97316, #ea580c)"
							title="Nutritional Goals"
							sub="Calories & macro targets"
							onClick={() => onNavigate("settings-goals")}
						/>
					</div>

					{/* Section: App Preferences */}
					<div className="section-label">Preferences</div>
					<div className="settings-group">
						<SettingItem
							icon={FiBell}
							color="linear-gradient(135deg, #8b5cf6, #7c3aed)"
							title="Notifications"
							sub="Reminders & alerts"
							onClick={() => onNavigate("settings-preferences")}
						/>
						<SettingItem
							icon={FiSmartphone}
							color="linear-gradient(135deg, #10b981, #059669)"
							title="Devices"
							badge={`${devicesActiveCount} Active`}
							onClick={() => onNavigate("settings-devices")}
						/>
						<SettingItem
							icon={FiSettings}
							color="linear-gradient(135deg, #64748b, #475569)"
							title="General"
							sub="Language, units, theme"
							onClick={() => onNavigate("settings-preferences")}
						/>
					</div>

					{/* Section: Support */}
					<div className="section-label">Support</div>
					<div className="settings-group">
						<SettingItem
							icon={FiHelpCircle}
							color="linear-gradient(135deg, #ec4899, #db2777)"
							title="Help & Support"
							onClick={() => onNavigate("settings-help")}
						/>
						<SettingItem
							icon={FiLogOut}
							color="transparent"
							title="Log Out"
							isDestructive
							onClick={() => setLogoutOpen(true)}
						/>
					</div>

					<div className="version-info">
						BioAI v2.4.0 • Build 2940
					</div>
				</div>
			</div>

			<LogoutModal
				open={logoutOpen}
				onClose={() => setLogoutOpen(false)}
			/>

			<div className={`toast ${toast ? "show" : ""}`}>{toast}</div>
		</div>
	);
}
