import React from "react";
import {
	FiChevronRight,
	FiLogOut,
	FiUser,
	FiTarget,
	FiHelpCircle,
	FiSmartphone,
} from "react-icons/fi";
import "./settings/settings.css";
import DevicesPanel from "./settings/DevicesPanel";
import PreferencesPanel from "./settings/PreferencesPanel";
import GoalsPanel from "./settings/GoalsPanel";
import ProfileForm from "./settings/ProfileForm";
import HelpPanel from "./settings/HelpPanel";
import LogoutModal from "./settings/LogoutModal";

export default function Settings() {
	const [openPanel, setOpenPanel] = React.useState(null);
	const [devicesActiveCount, setDevicesActiveCount] = React.useState(2);
	const [toast, setToast] = React.useState(null);
	const [logoutOpen, setLogoutOpen] = React.useState(false);

	function showToast(msg) {
		setToast(msg);
		setTimeout(() => setToast(null), 2000);
	}

	return (
		<div className="settings-root">
			<div className="settings-header">
				<h1>Settings</h1>
			</div>

			<div className="settings-scroll">
				{/* Profile Bar */}
				<div
					className="profile-bar"
					role="button"
					tabIndex={0}
					onClick={() => setOpenPanel("profile")}
				>
					<div className="profile-avatar">DE</div>
					<div className="profile-meta">
						<div className="profile-name">
							Dekomori{" "}
							<span
								style={{
									color: "#3b82f6",
									fontWeight: 700,
									fontSize: 13,
								}}
							>
								Premium Member
							</span>
						</div>
						<div className="profile-badges">
							<div className="badge">Daily Plan</div>
							<div className="badge">Auto Log</div>
						</div>
					</div>
					<div className="item-right">
						<div className="setting-sub">Manage account</div>
						<FiChevronRight />
					</div>
				</div>

				<div className="settings-list">
					<div
						className="setting-item"
						onClick={() => setOpenPanel("profile")}
					>
						<div
							style={{
								display: "flex",
								gap: 12,
								alignItems: "center",
							}}
						>
							<div className="setting-icon">
								<FiUser />
							</div>
							<div>
								<div className="setting-title">
									Profile & Body Stats
								</div>
								<div className="setting-sub">
									Edit name, weight, height
								</div>
							</div>
						</div>
						<div className="item-right">
							<FiChevronRight />
						</div>
					</div>

					<div
						className="setting-item"
						onClick={() => setOpenPanel("goals")}
					>
						<div
							style={{
								display: "flex",
								gap: 12,
								alignItems: "center",
							}}
						>
							<div className="setting-icon">🎯</div>
							<div>
								<div className="setting-title">
									Nutritional Goals
								</div>
								<div className="setting-sub">
									Set calorie & macros targets
								</div>
							</div>
						</div>
						<div className="item-right">
							<FiChevronRight />
						</div>
					</div>

					<div
						className="setting-item"
						onClick={() => setOpenPanel("preferences")}
					>
						<div
							style={{
								display: "flex",
								gap: 12,
								alignItems: "center",
							}}
						>
							<div className="setting-icon">⚙️</div>
							<div>
								<div className="setting-title">Preferences</div>
								<div className="setting-sub">
									App, notifications, privacy
								</div>
							</div>
						</div>
						<div className="item-right">
							<FiChevronRight />
						</div>
					</div>

					<div
						className="setting-item"
						onClick={() => setOpenPanel("devices")}
					>
						<div
							style={{
								display: "flex",
								gap: 12,
								alignItems: "center",
							}}
						>
							<div className="setting-icon">
								<FiSmartphone />
							</div>
							<div>
								<div className="setting-title">
									Connected Devices
								</div>
								<div className="setting-sub">
									{devicesActiveCount} Active
								</div>
							</div>
						</div>
						<div className="item-right">
							<div className="active-badge">
								{devicesActiveCount} Active
							</div>
							<FiChevronRight />
						</div>
					</div>

					<div
						className="setting-item"
						onClick={() => setOpenPanel("help")}
					>
						<div
							style={{
								display: "flex",
								gap: 12,
								alignItems: "center",
							}}
						>
							<div className="setting-icon">
								<FiHelpCircle />
							</div>
							<div>
								<div className="setting-title">
									Help & Support
								</div>
								<div className="setting-sub">
									Get help or open a support ticket
								</div>
							</div>
						</div>
						<div className="item-right">
							<FiChevronRight />
						</div>
					</div>

					<div
						className="setting-item"
						onClick={() => setLogoutOpen(true)}
					>
						<div
							style={{
								display: "flex",
								gap: 12,
								alignItems: "center",
							}}
						>
							<div className="setting-icon">⎋</div>
							<div>
								<div className="setting-title logout">
									Log Out
								</div>
								<div className="setting-sub">
									Sign out of this device
								</div>
							</div>
						</div>
						<div className="item-right">
							<FiLogOut />
						</div>
					</div>
				</div>
			</div>

			{/* Panels */}
			<DevicesPanel
				open={openPanel === "devices"}
				onClose={() => setOpenPanel(null)}
				onUpdateBadge={(c) => {
					setDevicesActiveCount(c);
					showToast(`${c} devices active`);
				}}
			/>
			<PreferencesPanel
				open={openPanel === "preferences"}
				onClose={() => {
					setOpenPanel(null);
					showToast("Preferences saved");
				}}
			/>
			<ProfileForm
				open={openPanel === "profile"}
				onClose={() => {
					setOpenPanel(null);
					showToast("Profile updated");
				}}
			/>
			<HelpPanel
				open={openPanel === "help"}
				onClose={() => {
					setOpenPanel(null);
					showToast("Support request sent");
				}}
			/>
			<GoalsPanel
				open={openPanel === "goals"}
				onClose={() => {
					setOpenPanel(null);
					showToast("Goals saved");
				}}
			/>

			<LogoutModal
				open={logoutOpen}
				onClose={() => setLogoutOpen(false)}
			/>

			<div className={`toast ${toast ? "show" : ""}`} role="status">
				{toast}
			</div>
		</div>
	);
}
