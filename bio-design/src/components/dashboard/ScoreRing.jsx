import React from "react";
import { FiPlus, FiInfo } from "react-icons/fi";

/**
 * Attempt to match the Asklepios Score gauge exactly:
 *   - 3 thick rounded arc segments (LOW, MEDIUM, HIGH) around a 270° sweep
 *   - Dashed outer guide circle
 *   - Labels positioned outside the arcs
 *   - Large centered score number
 *   - Blue + FAB at 6-o'clock
 */

// Arc helper: builds an SVG arc path from angle A→B (degrees, 0 = 12 o'clock, CW)
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
	const W = 240; // SVG viewBox width/height
	const cx = W / 2;
	const cy = W / 2;
	const R = 90; // main arc radius
	const SW = 18; // arc stroke width
	const guideR = R + 18; // dashed guide circle radius
	const guideCirc = 2 * Math.PI * guideR;

	// The 270° sweep goes from 225° (bottom-left) CW through top to 135° (bottom-right)
	// but in our coordinate system 0°=12 o'clock, so:
	//   LOW:    135° → 215°   (left side)
	//   MEDIUM: 225° → 315°   (top, wrapping around via 270°=left → 0°=top → 45°=right)
	//   HIGH:   325° →  45°   (right side)
	// Actually let me define in absolute degrees where 0=top, CW:
	//
	// The gauge opens at bottom (180°). Sweep = 270°.
	// Start at 225° (bottom-left), end at 135° (bottom-right) going CW.
	// With 10° gaps between segments:
	//   LOW:     225° → 310°  (85°, left side)
	//   gap:     310° → 320°
	//   MEDIUM:  320° → 40°   (80°, top)
	//   gap:     40°  → 50°
	//   HIGH:    50°  → 135°  (85°, right side)

	const segments = [
		{ start: 225, end: 310, color: "#6fb8ff" }, // LOW — light blue
		{ start: 320, end: 40, color: "#4a8fff" }, // MEDIUM — blue
		{ start: 50, end: 135, color: "#2b6fff" }, // HIGH — bold blue
	];

	// Label positions (outside the guide circle)
	const labelR = guideR + 14;
	const lowPos = posOnCircle(cx, cy, labelR, 267); // left
	const medPos = posOnCircle(cx, cy, labelR, 0); // top
	const highPos = posOnCircle(cx, cy, labelR, 93); // right

	return (
		<div className="score-ring-wrapper">
			<svg
				width="100%"
				height="100%"
				viewBox={`0 0 ${W} ${W}`}
				className="score-ring-svg"
			>
				{/* Dashed outer guide circle (270° arc, open at bottom) */}
				<path
					d={arcPath(cx, cy, guideR, 220, 140)}
					fill="none"
					stroke="#dde4ed"
					strokeWidth={1.5}
					strokeDasharray="4 4"
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
				<circle cx={cx} cy={cy} r={R - SW / 2 - 6} fill="white" />
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

			{/* Center content */}
			<div className="score-center">
				<div className="score-num">{value}</div>
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
