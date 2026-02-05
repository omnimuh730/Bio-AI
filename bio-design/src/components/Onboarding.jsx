import React, { useEffect, useMemo, useState } from "react";
import "../onboarding.css";

const GOALS = [
	{ id: "lose", label: "Lose weight" },
	{ id: "maintain", label: "Maintain" },
	{ id: "build", label: "Build muscle" },
];

const ALLERGIES = ["Nuts", "Dairy", "Gluten", "Shellfish", "Eggs"];
const TAGS = [
	"Pizza",
	"Biryani",
	"Noodles",
	"Seafood",
	"Salad",
	"Dessert",
	"Spicy",
	"Sushi",
	"Pasta",
];

export default function Onboarding({ onFinish }) {
	const [step, setStep] = useState(0);
	const [goal, setGoal] = useState(null);
	const [allergies, setAllergies] = useState([]);
	const [tagState, setTagState] = useState(() => ({}));
	const steps = 5;

	useEffect(() => {
		// If already completed onboarding once, silently finish
		try {
			const done = localStorage.getItem("bioai:onboarded");
			if (done && typeof onFinish === "function") onFinish();
		} catch (err) {
			console.warn("onboarding check failed", err);
		}
	}, [onFinish]);

	const toggleAllergy = (a) => {
		setAllergies((cur) =>
			cur.includes(a) ? cur.filter((x) => x !== a) : [...cur, a],
		);
	};

	const toggleTag = (t) => {
		setTagState((cur) => {
			const v = cur[t] || 0;
			const next = v === 0 ? 1 : v === 1 ? -1 : 0; // 0 -> liked(1) -> disliked(-1) -> 0
			return { ...cur, [t]: next };
		});
	};

	const next = () => setStep((s) => Math.min(steps - 1, s + 1));
	const prev = () => setStep((s) => Math.max(0, s - 1));
	const skip = () => {
		try {
			localStorage.setItem("bioai:onboarded", "1");
		} catch (err) { console.warn("skip save failed", err); }
		if (typeof onFinish === "function") onFinish();
	};

	const finish = () => {
		const payload = { goal, allergies, tags: tagState };
		try {
			localStorage.setItem("bioai:onboarded", "1");
			localStorage.setItem("bioai:profile", JSON.stringify(payload));
		} catch (err) { console.warn("save profile failed", err); }
		if (typeof onFinish === "function") onFinish();
	};

	const likedTags = useMemo(
		() => Object.keys(tagState).filter((k) => tagState[k] === 1),
		[tagState],
	);
	const dislikedTags = useMemo(
		() => Object.keys(tagState).filter((k) => tagState[k] === -1),
		[tagState],
	);

	return (
		<div className="onboarding-root">
			<div className="progress-row">
				<div
					className="progress"
					style={{ width: `${(step / (steps - 1)) * 100}%` }}
				/>
			</div>

			<div className={`slides step-${step}`}>
				{/* 0 - Intro */}
				<div className="slide">
					<div className="onboarding-card">
						<h2>
							Welcome to <span className="accent">bioai</span>
						</h2>
						<p className="muted">
							We'll ask a few quick questions to personalize
							recommendations.
						</p>
						<button className="next-btn" onClick={next}>
							Get started
						</button>
					</div>
				</div>

				{/* 1 - Goal */}
				<div className="slide">
					<div className="onboarding-card">
						<h3>What's your main goal?</h3>
						<div className="options-row">
							{GOALS.map((g) => (
								<button
									key={g.id}
									className={`option-card ${goal === g.id ? "active" : ""}`}
									onClick={() => setGoal(g.id)}
								>
									{g.label}
								</button>
							))}
						</div>
						<div className="hint muted">
							You can change this later.
						</div>
					</div>
				</div>

				{/* 2 - Allergies */}
				<div className="slide">
					<div className="onboarding-card">
						<h3>Any allergies?</h3>
						<div className="options-col">
							{ALLERGIES.map((a) => (
								<label
									key={a}
									className={`check ${allergies.includes(a) ? "checked" : ""}`}
								>
									<input
										type="checkbox"
										checked={allergies.includes(a)}
										onChange={() => toggleAllergy(a)}
									/>
									<span>{a}</span>
								</label>
							))}
						</div>
						<div className="hint muted">
							We'll hide items you're allergic to.
						</div>
					</div>
				</div>

				{/* 3 - Likes / Dislikes */}
				<div className="slide">
					<div className="onboarding-card">
						<h3>Tell us what you like (tap to like/dislike)</h3>
						<div className="tiles">
							{TAGS.map((t) => (
								<button
									key={t}
									className={`chip ${tagState[t] === 1 ? "liked" : tagState[t] === -1 ? "disliked" : ""}`}
									onClick={() => toggleTag(t)}
								>
									{t}
								</button>
							))}
						</div>
						<div className="hint muted">
							Green = like, muted = dislike.
						</div>
					</div>
				</div>

				{/* 4 - Summary */}
				<div className="slide">
					<div className="onboarding-card">
						<h3>All set!</h3>
						<div className="summary">
							<p>
								<strong>Goal:</strong> {goal || "Not set"}
							</p>
							<p>
								<strong>Allergies:</strong>{" "}
								{allergies.length
									? allergies.join(", ")
									: "None"}
							</p>
							<p>
								<strong>Likes:</strong>{" "}
								{likedTags.length ? likedTags.join(", ") : "—"}
							</p>
							<p>
								<strong>Dislikes:</strong>{" "}
								{dislikedTags.length
									? dislikedTags.join(", ")
									: "—"}
							</p>
						</div>
						<button className="next-btn" onClick={finish}>
							Finish
						</button>
					</div>
				</div>
			</div>

			<div className="onboarding-controls">
				{step > 0 ? (
					<button className="ghost" onClick={prev}>
						Back
					</button>
				) : (
					<button className="ghost" onClick={skip}>
						Skip
					</button>
				)}
				<div className="dots">
					{[0, 1, 2, 3, 4].map((i) => (
						<span
							key={i}
							className={`dot ${i === step ? "active" : ""}`}
							onClick={() => setStep(i)}
						/>
					))}
				</div>
				<button className="ghost" onClick={step === 4 ? finish : next}>
					{step === 4 ? "Finish" : "Next"}
				</button>
			</div>
		</div>
	);
}
