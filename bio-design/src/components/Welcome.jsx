import React from "react";
import "../welcome.css";

export default function Welcome({ onGetStarted }) {
	const circles = [
		{
			id: 0,
			url: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=300&q=80",
			size: 120,
			x: 40,
			y: 60,
		},
		{
			id: 1,
			url: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=300&q=80",
			size: 90,
			x: 250,
			y: 30,
		},
		{
			id: 2,
			url: "https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=300&q=80",
			size: 70,
			x: 30,
			y: 260,
		},
		{
			id: 3,
			url: "https://images.unsplash.com/photo-1626804475297-411d863452ef?auto=format&fit=crop&w=300&q=80",
			size: 100,
			x: 220,
			y: 220,
		},
	];

	return (
		<div className="welcome-screen">
			<div className="bubbles">
				{circles.map((c) => (
					<div
						key={c.id}
						className="bubble"
						style={{
							width: c.size,
							height: c.size,
							left: c.x,
							top: c.y,
							animationDelay: `${c.id * 0.6}s`,
							animationDuration: `${6 + c.id}s`,
						}}
					>
						<img src={c.url} alt="food" />
					</div>
				))}
			</div>

			<div className="welcome-body">
				<h2>
					Welcome to <span className="accent">Eatsy</span>{" "}
					<span className="wave">👋</span>
				</h2>
				<p className="muted">
					Unlock a world of culinary delights, right at your
					fingertips.
				</p>
				<button
					className="get-started"
					onClick={() => onGetStarted && onGetStarted()}
				>
					GET STARTED
				</button>
			</div>
		</div>
	);
}
