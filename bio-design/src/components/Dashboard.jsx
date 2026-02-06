import "./dashboard.css";
import Header from "./dashboard/Header";
import ScoreRing from "./dashboard/ScoreRing";
import AISuggestion from "./dashboard/AISuggestion";
import LiveVitals from "./dashboard/LiveVitals";
import QuickLog from "./dashboard/QuickLog";

export default function Dashboard() {
	return (
		<div className="dashboard-root">
			<Header />
			<div className="dashboard-scroll">
				<div className="hero-section">
					<ScoreRing value={88} />
				</div>
				<div className="widgets-grid">
					<AISuggestion />
					<LiveVitals />
					<div className="dual-row">
						<QuickLog />
					</div>
				</div>
			</div>
		</div>
	);
}
