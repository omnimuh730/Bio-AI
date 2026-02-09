import React from "react";
import "./settings.css";

export default function SlidePanel({ open, title, onClose, children, footer }) {
	return (
		<>
			<div
				className={`slide-panel-backdrop ${open ? "open" : ""}`}
				onClick={onClose}
			/>
			<aside
				className={`slide-panel ${open ? "open" : ""}`}
				aria-hidden={!open}
			>
				<div className="panel-header">
					<div style={{ flex: 1 }}>
						<div style={{ fontWeight: 800 }}>{title}</div>
						<div style={{ fontSize: 12, color: "#64748b" }}>
							Mock workflow • Demo data
						</div>
					</div>
					<button className="btn" onClick={onClose}>
						Close
					</button>
				</div>
				<div className="panel-body">{children}</div>
				{footer && <div className="panel-actions">{footer}</div>}
			</aside>
		</>
	);
}
