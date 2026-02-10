import "./styles/dashboard.css";
import Header from "./components/Header";
import ScoreRing from "./components/ScoreRing";
import LiveVitals from "./components/LiveVitals";
import QuickLog from "./components/QuickLog";
import RecommendedCard from "./components/RecommendedCard";

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
