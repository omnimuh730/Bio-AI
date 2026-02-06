import React from "react";
import { FiHome, FiBarChart2, FiUser, FiPlus } from "react-icons/fi";

export default function BottomNav() {
	return (
		<div className="db-bottom-nav">
			<div className="nav-left">
				<FiHome size={20} />
			</div>
			<div className="fab">
				<FiPlus size={26} />
			</div>
			<div className="nav-right">
				<FiUser size={20} />
			</div>
		</div>
	);
}
