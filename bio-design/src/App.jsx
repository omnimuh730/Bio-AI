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
		<div className="app-root">
			{screen === "splash" && (
				<Splash onFinish={() => setScreen("onboarding")} />
			)}
			{screen === "onboarding" && (
				<Onboarding onFinish={() => setScreen("home")} />
			)}
			{screen === "home" && <Home />}
		</div>
	);
}
