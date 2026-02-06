import React from "react";
import "./settings.css";

export default function LogoutModal({ open, onClose }) {
	if (!open) return null;
	function confirm() {
		// For demo, reload to get to splash (simple simulated logout)
		window.location.reload();
	}
	return (
		<div
			style={{
				position: "fixed",
				inset: 0,
				display: "flex",
				alignItems: "center",
				justifyContent: "center",
				zIndex: 130,
			}}
		>
			<div
				style={{
					position: "absolute",
					inset: 0,
					background: "rgba(8,10,19,0.45)",
				}}
				onClick={onClose}
			/>
			<div
				style={{
					background: "#fff",
					padding: 18,
					borderRadius: 12,
					boxShadow: "0 18px 40px rgba(2,6,23,0.18)",
					width: 380,
					maxWidth: "92%",
				}}
			>
				<h3 style={{ margin: 0 }}>Log Out</h3>
				<p style={{ color: "#64748b" }}>
					You're about to log out. This is a mock flow — we'll reload
					the app to simulate sign-out.
				</p>
				<div
					style={{
						display: "flex",
						gap: 8,
						justifyContent: "flex-end",
						marginTop: 12,
					}}
				>
					<button className="btn" onClick={onClose}>
						Cancel
					</button>
					<button className="btn primary" onClick={confirm}>
						Log Out
					</button>
				</div>
			</div>
		</div>
	);
}
