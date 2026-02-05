import React, { useState } from "react";
import "../onboarding.css";

export default function Onboarding({ onFinish }) {
	const [step, setStep] = useState(0);

	const next = () => setStep((s) => Math.min(2, s + 1));
	const prev = () => setStep((s) => Math.max(0, s - 1));

	return (
		<div className="onboarding-root">
			<div className={`slides step-${step}`}>
				{/* Slide 0 - Welcome */}
				<div className="slide">
					<div className="bubbles small">
						<div
							className="bubble"
							style={{
								left: 30,
								top: 60,
								width: 110,
								height: 110,
							}}
						>
							<img
								src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=300&q=80"
								alt="food"
							/>
						</div>
						<div
							className="bubble"
							style={{
								left: 240,
								top: 30,
								width: 80,
								height: 80,
							}}
						>
							<img
								src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=300&q=80"
								alt="food"
							/>
						</div>
						<div
							className="bubble"
							style={{
								left: 30,
								top: 260,
								width: 70,
								height: 70,
							}}
						>
							<img
								src="https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=300&q=80"
								alt="food"
							/>
						</div>
					</div>

					<div className="welcome-body compact">
						<h2>
							Welcome to <span className="accent">BioAI</span>
							<span className="wave">👋</span>
						</h2>
						<p className="muted">
							Unlock a world of culinary delights, right at your
							fingertips.
						</p>
						<button className="next-btn" onClick={next}>
							Next
						</button>
					</div>
				</div>

				{/* Slide 1 - Offer */}
				<div className="slide">
					<div className="onboarding-card">
						<div className="badge">30% OFF</div>
						<div className="card-title">Shrimp Noodles</div>
						<p className="card-sub">
							Special offers and hand-picked delights
						</p>
						<button className="secondary" onClick={next}>
							See Deals
						</button>
					</div>
				</div>

				{/* Slide 2 - CTA */}
				<div className="slide">
					<div className="onboarding-cta">
						<h3>Ready to eat?</h3>
						<p className="muted">
							Let's get you set up — find great food nearby.
						</p>
						<button
							className="get-started primary"
							onClick={() => onFinish && onFinish()}
						>
							GET STARTED
						</button>
					</div>
				</div>
			</div>

			{/* Controls */}
			<div className="onboarding-controls">
				<button className="ghost" onClick={prev} disabled={step === 0}>
					Back
				</button>
				<div className="dots">
					{[0, 1, 2].map((i) => (
						<span
							key={i}
							className={`dot ${i === step ? "active" : ""}`}
							onClick={() => setStep(i)}
						/>
					))}
				</div>
				<button className="ghost" onClick={next} disabled={step === 2}>
					Next
				</button>
			</div>
		</div>
	);
}
