import React, { useMemo, useState } from "react";
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
	const [pressedTag, setPressedTag] = useState(null);
	const steps = 5;

	// refs for swipe handling
	const slidesRef = React.useRef(null);
	const progressRef = React.useRef(null);
	const dragRef = React.useRef({
		active: false,
		startX: 0,
		deltaX: 0,
		width: 0,
		pointerId: null,
		lastX: 0,
		lastTime: 0,
		velocity: 0,
	});

	const updateProgress = React.useCallback((s, delta = 0) => {
		if (!slidesRef.current || !progressRef.current) return;
		const w = slidesRef.current.parentElement?.clientWidth || slidesRef.current.clientWidth || 1;
		const fractional = Math.min(
			steps - 1,
			Math.max(0, s - delta / w)
		);
		const pct = (fractional / (steps - 1)) * 100;
		progressRef.current.style.width = `${pct}%`;
	}, [steps]);

	const updateTransform = React.useCallback((s, delta = 0) => {
		if (!slidesRef.current) return;
		const w = slidesRef.current.parentElement?.clientWidth || slidesRef.current.clientWidth;
		const tx = Math.round(-(s * w) + delta);
	slidesRef.current.style.transform = `translateX(${tx}px)`;
		updateProgress(s, delta);
	}, [updateProgress]);

	const onPointerDown = (e) => {
		// If the pointerdown starts on an interactive control, don't start a drag
		const el = e.target;
		if (el && el.closest && el.closest("button, input, label, .ghost, .dot, .chip, .option-card")) {
			return;
		}
		if (!slidesRef.current) return;
		dragRef.current = {
			active: true,
			startX: e.clientX,
			deltaX: 0,
			width: slidesRef.current.parentElement?.clientWidth || slidesRef.current.clientWidth,
			pointerId: e.pointerId,
			captured: false,
			lastX: e.clientX,
			lastTime: performance.now(),
			velocity: 0,
		};
		slidesRef.current.style.transition = "none";
	};

	const onPointerMove = (e) => {
		if (!dragRef.current.active) return;
		const delta = e.clientX - dragRef.current.startX;
		const now = performance.now();
		const dt = Math.max(16, now - dragRef.current.lastTime);
		dragRef.current.velocity = (e.clientX - dragRef.current.lastX) / dt;
		dragRef.current.lastX = e.clientX;
		dragRef.current.lastTime = now;
		dragRef.current.deltaX = delta;
		// only engage capture when a clear horizontal drag starts; this prevents
		// accidental capture on taps so buttons remain clickable
		if (!dragRef.current.captured && Math.abs(delta) > 8) {
			try {
				slidesRef.current.setPointerCapture?.(e.pointerId);
				dragRef.current.captured = true;
				slidesRef.current.classList.add("dragging");
			} catch {
				/* ignore */
			}
		}
		if (dragRef.current.captured) {
			// lock to horizontal when user drags horizontally
			e.preventDefault();
			updateTransform(step, delta);
		}
	};

	const onPointerUp = () => {
		if (!dragRef.current.active || !slidesRef.current) return;
		const { deltaX, width, pointerId, captured, velocity } = dragRef.current;
		// if we never engaged capture, treat this as a tap and do nothing
		if (!captured) {
			dragRef.current = { active: false, startX: 0, deltaX: 0, width: 0, pointerId: null };
			return;
		}
		slidesRef.current.classList.remove("dragging");
		slidesRef.current.style.transition = "transform 320ms ease";
		try { slidesRef.current.releasePointerCapture?.(pointerId); } catch { /* ignore */ }

		const threshold = Math.max(50, width * 0.18);
		const projected = deltaX + velocity * 220;
		if (projected < -threshold && step < steps - 1) {
			setStep((s) => s + 1);
		} else if (projected > threshold && step > 0) {
			setStep((s) => s - 1);
		} else {
			updateTransform(step, 0);
		}
		dragRef.current = { active: false, startX: 0, deltaX: 0, width: 0, pointerId: null };
	};

	// sync visual position when step changes (if not dragging)
	React.useEffect(() => {
		if (dragRef.current.active) return;
		if (slidesRef.current) slidesRef.current.style.transition = "transform 320ms ease";
		updateTransform(step, 0);
	}, [step, updateTransform]);

	React.useEffect(() => {
		const onResize = () => updateTransform(step, 0);
		window.addEventListener("resize", onResize);
		return () => window.removeEventListener("resize", onResize);
	}, [step, updateTransform]);

	// NOTE: We intentionally do NOT auto-finish onboarding even if a previous
	// completion flag exists. This makes the flow re-discoverable for users
	// who want to reconfigure preferences. Previously we auto-called onFinish
	// here which caused onboarding to show and then immediately disappear.

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
		} catch (err) {
			console.warn("skip save failed", err);
		}
		if (typeof onFinish === "function") onFinish();
	};

	const finish = () => {
		const payload = { goal, allergies, tags: tagState };
		try {
			localStorage.setItem("bioai:onboarded", "1");
			localStorage.setItem("bioai:profile", JSON.stringify(payload));
		} catch (err) {
			console.warn("save profile failed", err);
		}
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
					ref={progressRef}
					className="progress"
					style={{ width: `${(step / (steps - 1)) * 100}%` }}
				/>
			</div>
			<div className="slides-viewport">
			<div
				ref={slidesRef}
				className={`slides step-${step}`}
				onPointerDown={onPointerDown}
				onPointerMove={onPointerMove}
				onPointerUp={onPointerUp}
				onPointerCancel={onPointerUp}
			>
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
									className={`chip ${pressedTag === t ? "pressing" : ""} ${tagState[t] === 1 ? "liked" : tagState[t] === -1 ? "disliked" : ""}`}
									onPointerDown={() => setPressedTag(t)}
									onPointerUp={() => setPressedTag(null)}
									onPointerLeave={() => setPressedTag(null)}
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
