import React from "react";
import { FiChevronRight, FiSettings } from "react-icons/fi";

export default function SetupCard() {
	return (
		<div className="card setup-card">
			<div className="setup-icon">
				<FiSettings size={20} />
			</div>
			<div className="setup-content">
				<div className="title">Complete your profile</div>
				<div className="sub">
					Add your height and weight for accurate calorie goals.
				</div>
			</div>
			<button className="setup-action">
				<FiChevronRight size={20} />
			</button>
		</div>
	);
}
