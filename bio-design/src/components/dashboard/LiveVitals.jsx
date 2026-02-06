import React from "react";
import { FiRefreshCw } from "react-icons/fi";

export default function LiveVitals() {
	return (
		<div className="card live-vitals">
			<div className="card-title">
				Live Vitals{" "}
				<button className="refresh">
					<FiRefreshCw />
				</button>
			</div>
			<div className="card-body">
				No live metrics yet. Connect a device to start streaming.
			</div>
		</div>
	);
}
