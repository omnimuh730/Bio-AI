import React from "react";
import {
	FiUser,
	FiSmartphone,
	FiTarget,
	FiHelpCircle,
	FiSettings,
	FiChevronRight,
	FiLogOut,
} from "react-icons/fi";

export default function Settings() {
	return (
		<div className="settings-root">
			<div className="settings-header">
				<h1>Settings</h1>
			</div>

			<div className="settings-scroll">
				{/* Profile Section */}
				<div className="profile-section">
					<img
						src="https://ui-avatars.com/api/?name=Dekomori&background=eef6ff&color=2b6fff&size=128"
						className="big-avatar"
						alt="profile"
					/>
					<h2>Dekomori</h2>
					<p>Premium Member</p>
				</div>

				<div className="menu-group">
					<div className="menu-item">
						<div className="icon">
							<FiUser />
						</div>
						<div className="label">Profile & Body Stats</div>
						<FiChevronRight className="arrow" />
					</div>
					<div className="menu-item">
						<div className="icon">
							<FiTarget />
						</div>
						<div className="label">Nutritional Goals</div>
						<FiChevronRight className="arrow" />
					</div>
					<div className="menu-item">
						<div className="icon">
							<FiSettings />
						</div>
						<div className="label">Preferences</div>
						<FiChevronRight className="arrow" />
					</div>
				</div>

				<div className="menu-group">
					<div className="menu-item">
						<div className="icon">
							<FiSmartphone />
						</div>
						<div className="label">Connected Devices</div>
						<div className="sub-tag">2 Active</div>
						<FiChevronRight className="arrow" />
					</div>
					<div className="menu-item">
						<div className="icon">
							<FiHelpCircle />
						</div>
						<div className="label">Help & Support</div>
						<FiChevronRight className="arrow" />
					</div>
				</div>

				<div className="menu-group danger">
					<div className="menu-item">
						<div className="icon">
							<FiLogOut />
						</div>
						<div className="label">Log Out</div>
					</div>
				</div>

				<div className="version">Bio AI v0.8.2 (Beta)</div>
			</div>

			<style>{`
				.settings-root {
					height: 100vh;
					background: #f8fafc;
					display: flex;
					flex-direction: column;
				}
				.settings-header {
					padding: 24px 20px 16px;
					background: #f8fafc;
				}
				.settings-header h1 { margin: 0; font-size: 24px; color: #0f172a; }
				
				.settings-scroll {
					flex: 1;
					overflow-y: auto;
					padding: 0 20px 100px;
				}
				
				.profile-section {
					display: flex; flexDirection: column; alignItems: center;
					margin-bottom: 32px;
				}
				.big-avatar {
					width: 80px; height: 80px; border-radius: 24px;
					box-shadow: 0 8px 24px rgba(59, 130, 246, 0.2);
					margin-bottom: 12px;
					border: 4px solid white;
				}
				.profile-section h2 { margin: 0; font-size: 20px; color: #0f172a; }
				.profile-section p { margin: 4px 0 0; color: #3b82f6; font-size: 13px; font-weight: 600; }

				.menu-group {
					background: white;
					border-radius: 16px;
					overflow: hidden;
					margin-bottom: 16px;
					box-shadow: 0 4px 12px rgba(0,0,0,0.02);
					border: 1px solid #f1f5f9;
				}
				.menu-item {
					display: flex; align-items: center; gap: 16px;
					padding: 16px;
					cursor: pointer;
					border-bottom: 1px solid #f8fafc;
				}
				.menu-item:last-child { border-bottom: none; }
				.menu-item:active { background: #f8fafc; }
				
				.menu-item .icon {
					width: 36px; height: 36px; background: #f1f5f9;
					border-radius: 10px; display: flex; align-items: center; justify-content: center;
					color: #64748b;
				}
				.menu-item .label {
					flex: 1; font-size: 14px; font-weight: 600; color: #334155;
				}
				.menu-item .arrow { color: #cbd5e1; }
				.sub-tag {
					font-size: 11px; color: #10b981; background: #ecfdf5;
					padding: 4px 8px; border-radius: 6px; font-weight: 600;
				}

				.menu-group.danger .menu-item .icon { background: #fee2e2; color: #ef4444; }
				.menu-group.danger .menu-item .label { color: #ef4444; }

				.version {
					text-align: center; color: #94a3b8; font-size: 11px; margin-top: 24px; opacity: 0.6;
				}
			`}</style>
		</div>
	);
}
