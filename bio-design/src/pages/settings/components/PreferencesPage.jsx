import React, { useState } from "react";
import {
	FiChevronLeft,
	FiMoon,
	FiBell,
	FiGlobe,
	FiShield,
	FiCheck,
	FiSmartphone,
	FiChevronRight,
	FiMapPin,
} from "react-icons/fi";

// --- Components ---

const LuxSwitch = ({ checked, onChange }) => (
	<div
		onClick={() => onChange(!checked)}
		style={{
			width: 50,
			height: 30,
			borderRadius: 30,
			background: checked ? "#10b981" : "#e2e8f0",
			padding: 3,
			cursor: "pointer",
			transition: "background 0.3s ease",
			position: "relative",
			flexShrink: 0,
		}}
	>
		<div
			style={{
				width: 24,
				height: 24,
				borderRadius: "50%",
				background: "white",
				boxShadow: "0 2px 5px rgba(0,0,0,0.2)",
				transform: checked ? "translateX(20px)" : "translateX(0)",
				transition: "transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1)",
			}}
		/>
	</div>
);

// The custom "Sheet" replacement for Select dropdowns
const SelectionSheet = ({
	isOpen,
	onClose,
	title,
	options,
	selected,
	onSelect,
}) => {
	if (!isOpen) return null;
	return (
		<div className="sheet-overlay" onClick={onClose}>
			<div className="sheet-content" onClick={(e) => e.stopPropagation()}>
				<div className="sheet-handle" />
				<h3 className="sheet-title">{title}</h3>
				<div className="sheet-options">
					{options.map((opt) => (
						<button
							key={opt.value}
							className={`sheet-option ${selected === opt.value ? "active" : ""}`}
							onClick={() => {
								onSelect(opt.value);
								onClose();
							}}
						>
							<span>{opt.label}</span>
							{selected === opt.value && (
								<FiCheck className="check-icon" />
							)}
						</button>
					))}
				</div>
				<button className="sheet-cancel" onClick={onClose}>
					Cancel
				</button>
			</div>
		</div>
	);
};

// Reusable Row Component
const PreferenceRow = ({
	icon: Icon,
	color,
	label,
	value,
	type = "arrow",
	onClick,
	isSwitch,
	switchValue,
}) => (
	<div className="pref-row" onClick={onClick}>
		<div
			className="icon-box"
			style={{ background: color.bg, color: color.text }}
		>
			<Icon size={18} />
		</div>
		<div className="pref-label">{label}</div>

		{type === "switch" ? (
			<LuxSwitch checked={switchValue} onChange={onClick} />
		) : (
			<div className="pref-value-container">
				{value && <span className="pref-value-text">{value}</span>}
				<FiChevronRight className="pref-arrow" />
			</div>
		)}
	</div>
);

// --- Main Page ---

export default function SettingsPreferences({ onBack }) {
	// State
	const [darkMode, setDarkMode] = useState(false);
	const [notifications, setNotifications] = useState(true);
	const [marketing, setMarketing] = useState(false);

	// Selection State
	const [activeMenu, setActiveMenu] = useState(null); // 'units', 'lang', 'region'

	const [settings, setSettings] = useState({
		units: "metric",
		language: "en",
		region: "us",
	});

	// Options Data
	const unitOptions = [
		{ label: "Metric (kg, cm, ml)", value: "metric" },
		{ label: "Imperial (lbs, ft, oz)", value: "imperial" },
	];
	const langOptions = [
		{ label: "English", value: "en" },
		{ label: "Japanese (日本語)", value: "jp" },
		{ label: "Spanish (Español)", value: "es" },
		{ label: "French (Français)", value: "fr" },
	];
	const regionOptions = [
		{ label: "United States", value: "us" },
		{ label: "Japan", value: "jp" },
		{ label: "Europe (EU)", value: "eu" },
		{ label: "Global", value: "global" },
	];

	const handleSelect = (key, val) => {
		setSettings((prev) => ({ ...prev, [key]: val }));
	};

	const getLabel = (options, val) =>
		options.find((o) => o.value === val)?.label.split(" (")[0];

	return (
		<div className="sub-page-container">
			{/* CSS-in-JS for this specific luxury page */}
			<style>{`
        .sub-page-container { background: #f8fafc; }
        .pref-section-title {
          font-size: 13px; font-weight: 700; color: #94a3b8;
          text-transform: uppercase; letter-spacing: 0.8px;
          margin: 28px 0 12px 12px;
        }
        
        .pref-card {
          background: #fff; border-radius: 20px; overflow: hidden;
          box-shadow: 0 4px 12px rgba(0,0,0,0.02);
          border: 1px solid rgba(0,0,0,0.02);
        }

        .pref-row {
          display: flex; align-items: center; padding: 16px 20px;
          cursor: pointer; transition: background 0.2s;
          border-bottom: 1px solid #f1f5f9;
        }
        .pref-row:last-child { border-bottom: none; }
        .pref-row:active { background: #f8fafc; }

        .icon-box {
          width: 36px; height: 36px; border-radius: 10px;
          display: flex; align-items: center; justify-content: center;
          margin-right: 14px; flex-shrink: 0;
        }

        .pref-label { flex: 1; font-weight: 600; color: #334155; font-size: 15px; }
        
        .pref-value-container { display: flex; align-items: center; gap: 8px; }
        .pref-value-text { font-size: 14px; color: #3b82f6; font-weight: 600; }
        .pref-arrow { color: #cbd5e1; }

        /* Bottom Sheet Styles */
        .sheet-overlay {
          position: fixed; inset: 0; z-index: 100;
          background: rgba(0,0,0,0.4); backdrop-filter: blur(4px);
          display: flex; align-items: flex-end;
          animation: fadeIn 0.3s ease;
        }
        .sheet-content {
          width: 100%; background: #fff;
          border-top-left-radius: 24px; border-top-right-radius: 24px;
          padding: 12px 24px 30px 24px;
          animation: slideUp 0.3s cubic-bezier(0.2, 0.8, 0.2, 1);
        }
        .sheet-handle {
          width: 40px; height: 4px; background: #e2e8f0; border-radius: 2px;
          margin: 0 auto 20px auto;
        }
        .sheet-title {
          text-align: center; font-size: 18px; font-weight: 700; margin-bottom: 20px;
          color: #1e293b;
        }
        .sheet-options { display: flex; flex-direction: column; gap: 8px; }
        .sheet-option {
          padding: 16px; border-radius: 16px; border: none;
          background: #f8fafc; color: #334155; font-weight: 600; font-size: 16px;
          display: flex; justify-content: space-between; align-items: center;
          cursor: pointer;
        }
        .sheet-option.active {
          background: #eff6ff; color: #2563eb;
        }
        .check-icon { font-size: 20px; color: #2563eb; }
        
        .sheet-cancel {
          width: 100%; padding: 16px; margin-top: 12px;
          background: transparent; border: none; color: #ef4444; font-weight: 700; font-size: 16px;
          cursor: pointer;
        }

        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        @keyframes slideUp { from { transform: translateY(100%); } to { transform: translateY(0); } }
      `}</style>

			<header className="sub-header">
				<button className="back-btn" onClick={onBack}>
					<FiChevronLeft size={24} />
				</button>
				<h2 className="sub-title">Preferences</h2>
			</header>

			<div className="sub-content">
				{/* Section: General */}
				<div className="pref-section-title">General</div>
				<div className="pref-card">
					<PreferenceRow
						icon={FiMoon}
						color={{ bg: "#f3f4f6", text: "#475569" }}
						label="Dark Mode"
						type="switch"
						switchValue={darkMode}
						onClick={() => setDarkMode(!darkMode)}
					/>
					<PreferenceRow
						icon={FiGlobe}
						color={{ bg: "#eff6ff", text: "#2563eb" }}
						label="Language"
						value={getLabel(langOptions, settings.language)}
						onClick={() => setActiveMenu("lang")}
					/>
					<PreferenceRow
						icon={FiMapPin}
						color={{ bg: "#fff7ed", text: "#ea580c" }}
						label="Region"
						value={getLabel(regionOptions, settings.region)}
						onClick={() => setActiveMenu("region")}
					/>
				</div>

				{/* Section: Data */}
				<div className="pref-section-title">Data & Units</div>
				<div className="pref-card">
					<PreferenceRow
						icon={FiSmartphone}
						color={{ bg: "#f0fdf4", text: "#16a34a" }}
						label="Measurement Units"
						value={getLabel(unitOptions, settings.units)}
						onClick={() => setActiveMenu("units")}
					/>
					<PreferenceRow
						icon={FiShield}
						color={{ bg: "#fef2f2", text: "#dc2626" }}
						label="Data Privacy"
						value="Active"
						onClick={() => {}}
					/>
				</div>

				{/* Section: Notifications */}
				<div className="pref-section-title">Notifications</div>
				<div className="pref-card">
					<PreferenceRow
						icon={FiBell}
						color={{ bg: "#fff1f2", text: "#e11d48" }}
						label="Push Notifications"
						type="switch"
						switchValue={notifications}
						onClick={() => setNotifications(!notifications)}
					/>
					<PreferenceRow
						icon={FiSmartphone}
						color={{ bg: "#faf5ff", text: "#9333ea" }}
						label="Marketing Emails"
						type="switch"
						switchValue={marketing}
						onClick={() => setMarketing(!marketing)}
					/>
				</div>
			</div>

			{/* --- Bottom Sheet Modals --- */}

			<SelectionSheet
				isOpen={activeMenu === "units"}
				onClose={() => setActiveMenu(null)}
				title="Select Units"
				options={unitOptions}
				selected={settings.units}
				onSelect={(val) => handleSelect("units", val)}
			/>

			<SelectionSheet
				isOpen={activeMenu === "lang"}
				onClose={() => setActiveMenu(null)}
				title="App Language"
				options={langOptions}
				selected={settings.language}
				onSelect={(val) => handleSelect("language", val)}
			/>

			<SelectionSheet
				isOpen={activeMenu === "region"}
				onClose={() => setActiveMenu(null)}
				title="Region Format"
				options={regionOptions}
				selected={settings.region}
				onSelect={(val) => handleSelect("region", val)}
			/>
		</div>
	);
}
