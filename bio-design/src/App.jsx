import "./index.css";
import "./splash.css";
import "./App.css";
import Splash from "./components/Splash";
import Onboarding from "./components/Onboarding";
import Home from "./components/Home";
import { useState } from "react";

export default function App() {
	const [screen, setScreen] = useState("splash");

	return (
		<div className="phone-preview-bg">
			<div className="phone-frame">
				<div className="notch" aria-hidden="true" />
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
						<Splash onFinish={() => setScreen("onboarding")} />
					)}
					{screen === "onboarding" && (
						<Onboarding onFinish={() => setScreen("home")} />
					)}
					{screen === "home" && <Home />}
				</div>
				<div className="home-indicator" />
			</div>
		</div>
	);
}
