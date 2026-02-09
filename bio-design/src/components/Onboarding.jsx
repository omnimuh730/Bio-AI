import React, {
	useMemo,
	useState,
	useRef,
	useEffect,
	useCallback,
} from "react";
import "../onboarding.css";

const GOALS = [
	{ id: "lose", label: "Lose Weight" },
	{ id: "maintain", label: "Maintain Health" },
	{ id: "build", label: "Build Muscle" },
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
	const [tagState, setTagState] = useState({});
	const totalSteps = 5;

	// Refs for drag physics
	const slidesRef = useRef(null);
	const viewportRef = useRef(null);
	const dragRef = useRef({
		active: false,
		startX: 0,
		currentX: 0,
		startTime: 0,
	});

	// --- Animation Logic ---

	// Calculates the CSS transform based on current step and drag delta
	const updateTransform = useCallback((currentStep, deltaX = 0) => {
		if (!slidesRef.current || !viewportRef.current) return;

		// Crucial fix: Measure exact visual width of the viewport
		const width = viewportRef.current.getBoundingClientRect().width;

		// Calculate position: -(Step * Width) + DragDelta
		const translateX = -(currentStep * width) + deltaX;

		slidesRef.current.style.transform = `translateX(${translateX}px)`;
	}, []);

	// Handle Resize: Recalculate position if window size changes
	useEffect(() => {
		const handleResize = () => updateTransform(step, 0);
		window.addEventListener("resize", handleResize);
		return () => window.removeEventListener("resize", handleResize);
	}, [step, updateTransform]);

	// Sync step changes (when not dragging)
	useEffect(() => {
		if (slidesRef.current) {
			slidesRef.current.style.transition =
				"transform 0.5s cubic-bezier(0.2, 0.8, 0.2, 1)";
		}
		updateTransform(step, 0);
	}, [step, updateTransform]);

	// --- Swipe / Touch Handlers ---

	const onPointerDown = (e) => {
		// Ignore swipe if clicking a button/interactive element
		if (e.target.closest("button, input, label, .interactive")) return;

		dragRef.current = {
			active: true,
			startX: e.clientX,
			currentX: e.clientX,
			startTime: Date.now(),
		};

		// Disable transition for instant follow
		if (slidesRef.current) {
			slidesRef.current.style.transition = "none";
		}
	};

	const onPointerMove = (e) => {
		if (!dragRef.current.active) return;

		const delta = e.clientX - dragRef.current.startX;
		dragRef.current.currentX = e.clientX;

		// Prevent dragging past bounds with resistance
		const isFirst = step === 0 && delta > 0;
		const isLast = step === totalSteps - 1 && delta < 0;

		const effectiveDelta = isFirst || isLast ? delta * 0.3 : delta; // Resistance

		updateTransform(step, effectiveDelta);
	};

	const onPointerUp = (e) => {
		if (!dragRef.current.active) return;
		dragRef.current.active = false;

		const delta = e.clientX - dragRef.current.startX;
		const duration = Date.now() - dragRef.current.startTime;
		const width =
			viewportRef.current?.getBoundingClientRect().width ||
			window.innerWidth;

		// Thresholds for swipe:
		// 1. Dragged more than 30% of screen
		// 2. Fast swipe (short duration + moderate distance)
		const threshold = width * 0.3;
		const isFastSwipe = duration < 250 && Math.abs(delta) > 20;

		if (slidesRef.current) {
			slidesRef.current.style.transition =
				"transform 0.5s cubic-bezier(0.2, 0.8, 0.2, 1)";
		}

		if (
			(delta < -threshold || (isFastSwipe && delta < 0)) &&
			step < totalSteps - 1
		) {
			setStep((s) => s + 1);
		} else if (
			(delta > threshold || (isFastSwipe && delta > 0)) &&
			step > 0
		) {
			setStep((s) => s - 1);
		} else {
			// Revert
			updateTransform(step, 0);
		}
	};

	// --- Data Handlers ---

	const toggleAllergy = (a) => {
		setAllergies((prev) =>
			prev.includes(a) ? prev.filter((x) => x !== a) : [...prev, a],
		);
	};

	const toggleTag = (t) => {
		setTagState((prev) => {
			const val = prev[t] || 0;
			// Cycle: 0 (neutral) -> 1 (like) -> -1 (dislike) -> 0
			const nextVal = val === 0 ? 1 : val === 1 ? -1 : 0;
			return { ...prev, [t]: nextVal };
		});
	};

	const handleFinish = () => {
		const payload = { goal, allergies, tags: tagState };
		try {
			localStorage.setItem("bioai:onboarded", "1");
			localStorage.setItem("bioai:profile", JSON.stringify(payload));
		} catch (e) {
			console.warn(e);
		}
		if (onFinish) onFinish();
	};

	const likedTags = useMemo(
		() => Object.keys(tagState).filter((k) => tagState[k] === 1),
		[tagState],
	);
	const dislikedTags = useMemo(
		() => Object.keys(tagState).filter((k) => tagState[k] === -1),
		[tagState],
	);

	// --- Render Helpers ---

	return (
		<div className="onboarding-root">
			{/* 1. Top Progress Bar */}
			<div className="progress-container">
				<div className="progress-track">
					<div
						className="progress-fill"
						style={{ width: `${((step + 1) / totalSteps) * 100}%` }}
					/>
				</div>
			</div>

			{/* 2. Main Slider Viewport */}
			<div className="slides-viewport" ref={viewportRef}>
				<div
					className="slides"
					ref={slidesRef}
					onPointerDown={onPointerDown}
					onPointerMove={onPointerMove}
					onPointerUp={onPointerUp}
					onPointerCancel={onPointerUp}
					onPointerLeave={onPointerUp}
				>
					{/* Step 0: Welcome */}
					<div className="slide">
						<div className="card-content">
							<h2>
								Welcome to <span className="accent">bioai</span>
							</h2>
							<p className="muted">
								Your personal health companion. Let's get to
								know you better in just 30 seconds.
							</p>
							<button
								className="start-btn interactive"
								onClick={() => setStep(1)}
							>
								Get Started
							</button>
						</div>
					</div>

					{/* Step 1: Goal */}
					<div className="slide">
						<div className="card-content">
							<h3>What's your focus?</h3>
							<p className="muted">
								We'll tailor recommendations to this.
							</p>
							<div className="options-grid">
								{GOALS.map((g) => (
									<button
										key={g.id}
										className={`option-btn interactive ${goal === g.id ? "selected" : ""}`}
										onClick={() => setGoal(g.id)}
									>
										{g.label}
									</button>
								))}
							</div>
						</div>
					</div>

					{/* Step 2: Allergies */}
					<div className="slide">
						<div className="card-content">
							<h3>Any dietary restrictions?</h3>
							<p className="muted">Select all that apply.</p>
							<div className="allergy-list">
								{ALLERGIES.map((a) => (
									<div
										key={a}
										className={`allergy-item interactive ${allergies.includes(a) ? "active" : ""}`}
										onClick={() => toggleAllergy(a)}
									>
										<span>{a}</span>
										<div className="checkbox-circle" />
									</div>
								))}
							</div>
						</div>
					</div>

					{/* Step 3: Likes/Dislikes */}
					<div className="slide">
						<div className="card-content">
							<h3>Taste Profile</h3>
							<p className="muted">
								Tap once to{" "}
								<span style={{ color: "green" }}>like</span>,
								twice to{" "}
								<span style={{ color: "red" }}>dislike</span>.
							</p>
							<div className="tag-cloud">
								{TAGS.map((t) => (
									<button
										key={t}
										className={`tag-chip interactive ${tagState[t] === 1 ? "liked" : tagState[t] === -1 ? "disliked" : ""}`}
										onClick={() => toggleTag(t)}
									>
										{t}
									</button>
								))}
							</div>
						</div>
					</div>

					{/* Step 4: Summary */}
					<div className="slide">
						<div className="card-content">
							<h3>All set!</h3>
							<p className="muted">Here is your BioAI profile.</p>

							<div className="summary-list">
								<div className="summary-row">
									<span className="summary-label">Goal</span>
									<span className="summary-val">
										{GOALS.find((g) => g.id === goal)
											?.label || "Not Set"}
									</span>
								</div>
								<div className="summary-row">
									<span className="summary-label">
										Allergies
									</span>
									<span className="summary-val">
										{allergies.length
											? allergies.join(", ")
											: "None"}
									</span>
								</div>
								<div className="summary-row">
									<span className="summary-label">Likes</span>
									<span className="summary-val">
										{likedTags.length
											? likedTags.join(", ")
											: "—"}
									</span>
								</div>
								<div className="summary-row">
									<span className="summary-label">
										Dislikes
									</span>
									<span className="summary-val">
										{dislikedTags.length
											? dislikedTags.join(", ")
											: "—"}
									</span>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

			{/* 3. Bottom Controls (Navigation) */}
			<div className="bottom-controls">
				{step > 0 ? (
					<button
						className="nav-btn"
						onClick={() => setStep((s) => s - 1)}
					>
						Back
					</button>
				) : (
					<button
						className="nav-btn"
						onClick={() => {
							// Logic to skip or just do nothing
							handleFinish();
						}}
					>
						Skip
					</button>
				)}

				{step > 0 && (
					<button
						className={`primary-btn ${step === totalSteps - 1 ? "finish" : ""}`}
						onClick={
							step === totalSteps - 1
								? handleFinish
								: () => setStep((s) => s + 1)
						}
					>
						{step === totalSteps - 1 ? "Finish Setup" : "Continue"}
					</button>
				)}
			</div>
		</div>
	);
}
