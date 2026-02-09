import React from "react";
import { FiCopy } from "react-icons/fi";

export default function QuickLog() {
	const handleCopy = () => {
		navigator.clipboard?.writeText("Oatmeal and berries — 320 kcal");
		alert("Copied to clipboard");
	};

	return (
		<div className="card quick-log">
			<div className="row">
				<div>
					<div className="title">Copy Yesterday Breakfast</div>
					<div className="sub">Oatmeal and berries — 320 kcal</div>
				</div>
				<button className="copy" onClick={handleCopy}>
					<FiCopy />
				</button>
			</div>
		</div>
	);
}
