import React from "react";
import { FiBell } from "react-icons/fi";

export default function Header() {
	return (
		<div className="db-header">
			<div className="greeting">
				<h1>Hello, Dekomori</h1>
				<div className="setup">
					Finish your setup
					<button className="continue">Continue</button>
				</div>
			</div>
			<div className="icon-bell">
				<FiBell size={20} />
			</div>
		</div>
	);
}
