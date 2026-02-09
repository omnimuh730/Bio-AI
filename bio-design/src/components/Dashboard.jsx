import "./dashboard.css";
import Header from "./dashboard/Header";
import ScoreRing from "./dashboard/ScoreRing";
import LiveVitals from "./dashboard/LiveVitals";
import QuickLog from "./dashboard/QuickLog";
import RecommendedCard from "./dashboard/RecommendedCard";

export default function Dashboard({ onNavigate }) {
	const handleNavigate = (page) => {
		if (onNavigate) {
			onNavigate(page);
		} else {
			console.warn("onNavigate prop missing in Dashboard");
		}
	};

	return (
		<div className="dashboard-root">
			<Header />
			<div className="dashboard-scroll">
				<div className="hero-section">
					<ScoreRing value={88} />
				</div>
				<div className="widgets-grid">
					<RecommendedCard
						onOpen={() => handleNavigate("recommended")}
					/>
					<LiveVitals />
					<div className="dual-row">
						<QuickLog />
					</div>
				</div>
			</div>
		</div>
	);
}
