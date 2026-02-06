import React from "react";
import { FiPlus, FiInfo } from "react-icons/fi";

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

	const W = 240;
	const cx = W / 2;
	const cy = W / 2;
	const R = 90;
	const SW = 18;
	const guideR = R + 18;
	const guideCirc = 2 * Math.PI * guideR;

	// Gauge geometry: 270 degree sweep from 225 (bottom-left) to 135 (bottom-right)
	const startAngle = 225;
	const maxSweep = 270;
	const endAngle = startAngle + maxSweep;

	// Calculate filled arc
	const currentSweep = (displayValue / 100) * maxSweep;
	// Ensure end angle doesn't go backwards if sweep is 0
	const currentEndAngle = startAngle + Math.max(0.1, currentSweep);

	// Indicator position
	const indicatorDeg = (startAngle + currentSweep) % 360;
	const indicatorR = R + SW / 2 - 2;
	const indicatorPos = posOnCircle(cx, cy, indicatorR, indicatorDeg);

	const shownValue = Math.round(displayValue);

	// Label positions
	const labelR = guideR + 14;
	const lowPos = posOnCircle(cx, cy, labelR, 260);
	const medPos = posOnCircle(cx, cy, labelR, 0);
	const highPos = posOnCircle(cx, cy, labelR, 100);

	return (
		<div className="score-ring-wrapper">
			<svg
				width="100%"
				height="100%"
				viewBox={`0 0 ${W} ${W}`}
				className="score-ring-svg"
			>
				<defs>
					<linearGradient
						id="scoreGradient"
						x1="0%"
						y1="0%"
						x2="100%"
						y2="0%"
					>
						<stop offset="0%" stopColor="#6fb8ff" />
						<stop offset="50%" stopColor="#4a8fff" />
						<stop offset="100%" stopColor="#2b6fff" />
					</linearGradient>
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

				{/* Dashed outer guide circle */}
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

				{/* Background Track (full 270 sweep) */}
				<path
					d={arcPath(cx, cy, R, startAngle, endAngle)}
					fill="none"
					stroke="#e2e8f0"
					strokeWidth={SW}
					strokeLinecap="round"
				/>

				{/* Foreground Value Arc */}
				<path
					d={arcPath(cx, cy, R, startAngle, currentEndAngle)}
					fill="none"
					stroke="url(#scoreGradient)"
					strokeWidth={SW}
					strokeLinecap="round"
				/>

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

			{/* Labels */}
			<span
				className="ring-lbl"
				style={{ left: lowPos.x, top: lowPos.y }}
			>
				LOW
			</span>
			<span
				className="ring-lbl"
				style={{ left: medPos.x, top: medPos.y }}
			>
				MEDIUM
			</span>
			<span
				className="ring-lbl"
				style={{ left: highPos.x, top: highPos.y }}
			>
				HIGH
			</span>

			{/* Indicator Dot */}
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
