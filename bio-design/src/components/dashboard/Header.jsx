import React from "react";
import { FiBell } from "react-icons/fi";

export default function Header() {
	return (
		<div className="db-header">
			<div className="header-top">
				<div className="greeting">
					<div className="welcome-text">Good Morning,</div>
					<h1>Dekomori</h1>
				</div>
				<div className="header-actions">
					<div className="user-avatar">
						<img src="https://ui-avatars.com/api/?name=Dekomori&background=eef6ff&color=2b6fff" alt="User" />
					</div>
					<div className="icon-bell">
						<FiBell size={20} />
						<span className="badge">2</span>
					</div>
				</div>
			</div>
		</div>
	);
}
