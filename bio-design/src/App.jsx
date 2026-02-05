import "./index.css";
import "./splash.css";
import Splash from "./components/Splash";
import Welcome from "./components/Welcome";
import Boti from "./components/Boti";
import { useState } from "react";

export default function App() {
	const [screen, setScreen] = useState("splash");

	return (
		<div className="phone-preview-bg">
			<div className="phone-frame">
				{/* status bar */}
				<div className="status-bar">
					<div className="status-left">10:40</div>
					<div className="status-right">
						<span className="dot" />
						<span className="dot" />
						<span className="dot" />
					</div>
				</div>

				{/* content area (screens will render here) */}
				<div className="content-area">
					{screen === "splash" && (
						<Splash onFinish={() => setScreen("welcome")} />
					)}
					{screen === "welcome" && (
						<Welcome onGetStarted={() => setScreen("home")} />
					)}
					{screen === "home" && <Boti />}
				</div>

				{/* home indicator */}
				<div className="home-indicator" />
			</div>
		</div>
	);
}
