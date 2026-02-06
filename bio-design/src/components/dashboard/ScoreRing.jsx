import React from "react";
import { FiPlus, FiInfo } from "react-icons/fi";

/**
 * Attempt to match the Asklepios Score gauge:
 *   - 3 thick rounded arc segments (LOW, MEDIUM, HIGH) around a 270-degree sweep
 *   - Dashed outer guide circle
 *   - Labels positioned outside the arcs
 *   - Large centered score number
 *   - Blue + FAB at 6 o'clock
 */

const clamp = (value, min, max) => Math.min(max, Math.max(min, value));

// Arc helper: builds an SVG arc path from angle A to B (degrees, 0 = 12 o'clock, CW)
function arcPath(cx, cy, r, startDeg, endDeg) {
	const toRad = (d) => ((d - 90) * Math.PI) / 180;
	const x1 = cx + r * Math.cos(toRad(startDeg));
	const y1 = cy + r * Math.sin(toRad(startDeg));
	const x2 = cx + r * Math.cos(toRad(endDeg));
	const y2 = cy + r * Math.sin(toRad(endDeg));
	const extent = endDeg - startDeg;
	const large = extent > 180 ? 1 : 0;
	return `M ${x1} ${y1} A ${r} ${r} 0 ${large} 1 ${x2} ${y2}`;
}

// Position helper: get x,y on a circle at a given clock-angle
function posOnCircle(cx, cy, r, deg) {
	const rad = ((deg - 90) * Math.PI) / 180;
	return { x: cx + r * Math.cos(rad), y: cy + r * Math.sin(rad) };
}

export default function ScoreRing({ value = 88 }) {
	const [displayValue, setDisplayValue] = React.useState(0);
	const displayValueRef = React.useRef(0);
	const rafRef = React.useRef(null);

	React.useEffect(() => {
		const target = clamp(value, 0, 100);
		const startValue = displayValueRef.current;
		const startTime = performance.now();
		const duration = 1200;
		const easeOutCubic = (t) => 1 - Math.pow(1 - t, 3);

		const tick = (now) => {
			const t = Math.min((now - startTime) / duration, 1);
			const nextValue =
				startValue + (target - startValue) * easeOutCubic(t);
			displayValueRef.current = nextValue;
			setDisplayValue(nextValue);
			if (t < 1) {
				rafRef.current = requestAnimationFrame(tick);
			}
		};

		if (rafRef.current) {
			cancelAnimationFrame(rafRef.current);
		}
		rafRef.current = requestAnimationFrame(tick);

		return () => {
			if (rafRef.current) {
				cancelAnimationFrame(rafRef.current);
			}
		};
	}, [value]);

	const W = 240; // SVG viewBox width/height
	const cx = W / 2;
	const cy = W / 2;
	const R = 90; // main arc radius
	const SW = 18; // arc stroke width
	const guideR = R + 18; // dashed guide circle radius
	const guideCirc = 2 * Math.PI * guideR;

	// The gauge opens at bottom (180 degrees). Sweep = 270 degrees.
	// Start at 225 degrees (bottom-left), end at 135 degrees (bottom-right) going CW.
	// With 10 degree gaps between segments:
	//   LOW:     225 -> 310 (85 degrees, left side)
	//   gap:     310 -> 320
	//   MEDIUM:  320 -> 40  (80 degrees, top)
	//   gap:     40  -> 50
	//   HIGH:    50  -> 135 (85 degrees, right side)

	const segments = [
		{ start: 225, end: 310, color: "#6fb8ff" }, // LOW - light blue
		{ start: 320, end: 353, color: "#4a8fff" }, // MEDIUM left half
		{ start: 7, end: 40, color: "#4a8fff" }, // MEDIUM right half
		{ start: 50, end: 135, color: "#2b6fff" }, // HIGH - bold blue
	];

	// Label positions (outside the guide circle)
	const labelR = guideR + 14;
	const lowPos = posOnCircle(cx, cy, labelR, 267); // left
	const medPos = posOnCircle(cx, cy, labelR, 0); // top
	const highPos = posOnCircle(cx, cy, labelR, 93); // right

	const clampedDisplay = clamp(displayValue, 0, 100);
	const gaugeStart = 225;
	const gaugeSweep = 270;
	const indicatorDeg =
		(gaugeStart + (clampedDisplay / 100) * gaugeSweep) % 360;
	const indicatorR = R + SW / 2 - 2;
	const indicatorPos = posOnCircle(cx, cy, indicatorR, indicatorDeg);
	const shownValue = Math.round(clampedDisplay);

	return (
		<div className="score-ring-wrapper">
			<svg
				width="100%"
				height="100%"
				viewBox={`0 0 ${W} ${W}`}
				className="score-ring-svg"
			>
				<defs>
					<filter
						id="score-inner-shadow"
						x="-30%"
						y="-30%"
						width="160%"
						height="160%"
					>
						<feDropShadow
							dx="0"
							dy="4"
							stdDeviation="4"
							floodColor="#d6dde7"
							floodOpacity="0.7"
						/>
					</filter>
				</defs>

				{/* Dashed outer guide circle (full 360 degrees) */}
				<circle
					cx={cx}
					cy={cy}
					r={guideR}
					fill="none"
					stroke="#dde4ed"
					strokeWidth={1.5}
					strokeDasharray="4 4"
					strokeDashoffset={guideCirc * 0.1}
				/>

				{/* Three arc segments */}
				{segments.map((seg, i) => {
					const end = seg.end < seg.start ? seg.end + 360 : seg.end;
					return (
						<path
							key={i}
							d={arcPath(
								cx,
								cy,
								R,
								seg.start,
								end > 360 ? end - 360 + 360 : end,
							)}
							fill="none"
							stroke={seg.color}
							strokeWidth={SW}
							strokeLinecap="round"
						/>
					);
				})}

				{/* Inner white circle background */}
				<circle
					cx={cx}
					cy={cy}
					r={R - SW / 2 - 6}
					fill="white"
					filter="url(#score-inner-shadow)"
				/>
				<circle
					cx={cx}
					cy={cy}
					r={R - SW / 2 - 6}
					fill="none"
					stroke="#f0f3f7"
					strokeWidth={1}
				/>
			</svg>

			{/* Labels around the ring */}
			<span
				className="ring-lbl ring-lbl-low"
				style={{ left: lowPos.x, top: lowPos.y }}
			>
				LOW
			</span>
			<span
				className="ring-lbl ring-lbl-med"
				style={{ left: medPos.x, top: medPos.y }}
			>
				MEDIUM
			</span>
			<span
				className="ring-lbl ring-lbl-high"
				style={{ left: highPos.x, top: highPos.y }}
			>
				HIGH
			</span>

			{/* Score indicator */}
			<div
				className="score-indicator"
				style={{ left: indicatorPos.x, top: indicatorPos.y }}
				aria-hidden="true"
			/>

			{/* Center content */}
			<div className="score-center">
				<div className="score-num">{shownValue}</div>
				<div className="score-of">Out of 100</div>
				<div className="score-name">
					Asklepios Score <FiInfo size={11} />
				</div>
			</div>

			{/* Plus FAB */}
			<button className="score-fab" aria-label="Add">
				<FiPlus size={20} strokeWidth={3} />
			</button>
		</div>
	);
}
