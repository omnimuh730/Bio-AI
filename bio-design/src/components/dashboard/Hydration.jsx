import React from "react";
import { FiDroplet, FiPlus } from "react-icons/fi";

const data = { current: 1250, goal: 2500 };

export default function Hydration() {
	return (
		<div className="card hydration">
			<div className="card-title">Hydration</div>
			<div className="hydration-row">
				<div className="drop">
					<FiDroplet size={22} color="#2b8cff" />
				</div>
				<div className="amount">
					{data.current.toLocaleString()}ml
					<br />
					<span>Goal: {data.goal.toLocaleString()}ml</span>
				</div>
				<div className="btns">
					<button>
						<FiPlus /> +250
					</button>
					<button>
						<FiPlus /> +500
					</button>
				</div>
			</div>
		</div>
	);
}
