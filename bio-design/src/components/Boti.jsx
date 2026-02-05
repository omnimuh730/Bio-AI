import React from "react";
import "../boti.css";

export default function Boti() {
	return (
		<div className="boti-root">
			<div className="header">
				<i className="fas fa-bars menu-icon" />
				<div className="logo-area">
					<div className="logo-arc" />
					<div className="app-name">
						Bon appetit<span>!</span>
					</div>
				</div>
				<i className="fas fa-bell profile-icon" />
			</div>

			<div className="home-sample">
				<h3 style={{ color: "#fff", marginTop: 140 }}>
					Home Screen (Sample)
				</h3>
				<p style={{ color: "#ccc" }}>
					This is the main app content inside the device mock.
				</p>
			</div>
		</div>
	);
}
