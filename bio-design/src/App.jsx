import "./index.css";
import "./App.css";
import Splash from "./pages/splash";
import Onboarding from "./pages/onboarding";
import Home from "./pages/Home";
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
