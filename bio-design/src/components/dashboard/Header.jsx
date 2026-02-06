import React from "react";
import { FiBell } from "react-icons/fi";
import ScoreRing from "./ScoreRing";

export default function Header() {
	return (
		<div className="db-header">
			<div className="header-top">
				<div className="greeting">
					<h1>Hello, Dekomori</h1>
				</div>
				<div className="icon-bell">
					<FiBell size={20} />
				</div>
			</div>

			<ScoreRing value={88} />
		</div>
	);
}
