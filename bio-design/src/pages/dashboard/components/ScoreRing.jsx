import React from "react";
import { FiInfo, FiDroplet } from "react-icons/fi";

const clamp = (value, min, max) => Math.min(max, Math.max(min, value));

// --- SVG Helpers ---
function arcPath(cx, cy, r, startDeg, endDeg) {
	const toRad = (d) => ((d - 90) * Math.PI) / 180;
	const x1 = cx + r * Math.cos(toRad(startDeg));
	const y1 = cy + r * Math.sin(toRad(startDeg));
	const x2 = cx + r * Math.cos(toRad(endDeg));
	const y2 = cy + r * Math.sin(toRad(endDeg));

	// Logic to handle full circles or large arcs
	const extent = endDeg - startDeg;
	const large = extent > 180 ? 1 : 0;

	// If end matches start, draw nothing or full circle (handled outside)
	if (extent <= 0) return "";

	return `M ${x1} ${y1} A ${r} ${r} 0 ${large} 1 ${x2} ${y2}`;
}

function posOnCircle(cx, cy, r, deg) {
	const rad = ((deg - 90) * Math.PI) / 180;
	return { x: cx + r * Math.cos(rad), y: cy + r * Math.sin(rad) };
}

export default function ScoreRing({
	score = 88,
	hydration = 65, // 0 to 100
}) {
	// --- Score Animation ---
	const [displayScore, setDisplayScore] = React.useState(0);

	React.useEffect(() => {
		let start = 0;
		const end = clamp(score, 0, 100);
		const duration = 1500;
		const startTime = performance.now();

		const animate = (currentTime) => {
			const elapsed = currentTime - startTime;
			const progress = Math.min(elapsed / duration, 1);
			// Ease out cubic
			const ease = 1 - Math.pow(1 - progress, 3);

			setDisplayScore(start + (end - start) * ease);

			if (progress < 1) {
				requestAnimationFrame(animate);
			}
		};
		requestAnimationFrame(animate);
	}, [score]);

	// --- Geometry Constants ---
	const W = 280; // Total Width
	const cx = W / 2;
	const cy = W / 2;
	const R = 90; // Ring Radius
	const SW = 20; // Stroke Width
	const guideR = R + 30; // Dashed line radius

	// The inner circle where water sits (Radius - Stroke/2)
	const innerRadius = R - SW / 2;

	// --- Ring Calculations ---
	const startAngle = 220; // Slightly adjusted for aesthetics
	const maxSweep = 280;
	const endAngle = startAngle + maxSweep;

	const currentSweep = (displayScore / 100) * maxSweep;
	const currentEndAngle = startAngle + Math.max(0.01, currentSweep);

	// Indicator Position
	const indicatorDeg = (startAngle + currentSweep) % 360;
	const indicatorPos = posOnCircle(cx, cy, R, indicatorDeg);

	// Labels Positions
	const labelR = guideR + 15;
	const lowPos = posOnCircle(cx, cy, labelR, 250);
	const medPos = posOnCircle(cx, cy, labelR, 0); // Top
	const highPos = posOnCircle(cx, cy, labelR, 110);

	return (
		<div className="gauge-container">
			{/* 1. Hydration Fill (Background Layer) */}
			<div
				className="hydration-mask"
				style={{
					width: innerRadius * 2,
					height: innerRadius * 2,
					left: cx - innerRadius,
					top: cy - innerRadius,
				}}
			>
				<div
					className="hydration-fill"
					style={{ height: `${clamp(hydration, 0, 100)}%` }}
				/>
				{/* Glass Reflection Overlay */}
				<div className="glass-shine" />
			</div>

			{/* 2. The Score Ring (SVG Layer) */}
			<svg
				width={W}
				height={W}
				viewBox={`0 0 ${W} ${W}`}
				className="gauge-svg"
			>
				<defs>
					<linearGradient
						id="scoreGradient"
						x1="0%"
						y1="0%"
						x2="100%"
						y2="0%"
					>
						<stop offset="0%" stopColor="#3b82f6" />
						<stop offset="100%" stopColor="#2563eb" />
					</linearGradient>
				</defs>

				{/* Dashed Guide Circle */}
				<circle
					cx={cx}
					cy={cy}
					r={guideR}
					fill="none"
					stroke="#cbd5e1"
					strokeWidth={1}
					strokeDasharray="4 6"
				/>

				{/* Track Background */}
				<path
					d={arcPath(cx, cy, R, startAngle, endAngle)}
					fill="none"
					stroke="#f1f5f9" // Very light gray/white
					strokeWidth={SW}
					strokeLinecap="round"
				/>

				{/* Active Score Arc */}
				<path
					d={arcPath(cx, cy, R, startAngle, currentEndAngle)}
					fill="none"
					stroke="url(#scoreGradient)"
					strokeWidth={SW}
					strokeLinecap="round"
					style={{
						filter: "drop-shadow(0 4px 6px rgba(37, 99, 235, 0.3))",
					}}
				/>
			</svg>

			{/* 3. HTML Overlays (Labels & Indicator) */}

			{/* Indicator Dot (HTML for easier shadow/border styling) */}
			<div
				className="indicator-dot"
				style={{
					left: indicatorPos.x,
					top: indicatorPos.y,
					opacity: displayScore > 0 ? 1 : 0,
				}}
			/>

			{/* Outer Labels */}
			<span
				className="ring-label"
				style={{ left: lowPos.x, top: lowPos.y }}
			>
				LOW
			</span>
			<span
				className="ring-label"
				style={{ left: medPos.x, top: medPos.y }}
			>
				MEDIUM
			</span>
			<span
				className="ring-label"
				style={{ left: highPos.x, top: highPos.y }}
			>
				HIGH
			</span>

			{/* 4. Center Content */}
			<div className="center-content">
				<div className="score-val">{Math.round(displayScore)}</div>
				<div className="score-sub">OUT OF 100</div>

				<div className="score-title">
					Score{" "}
					<FiInfo size={12} style={{ marginLeft: 4, opacity: 0.5 }} />
				</div>

				{/* Hydration Stat */}
				<div className="hydration-stat">
					<FiDroplet size={10} className="drop-icon" />
					<span>{Math.round(hydration)}% Hydrated</span>
				</div>
			</div>

			<style>{`
        .gauge-container {
          position: relative;
          width: ${W}px;
          height: ${W}px;
          margin: 0 auto;
          font-family: 'Inter', system-ui, -apple-system, sans-serif;
          user-select: none;
        }

        .gauge-svg {
          position: relative;
          z-index: 10;
          overflow: visible;
        }

        /* --- Hydration Fill Logic --- */
        .hydration-mask {
          position: absolute;
          border-radius: 50%;
          overflow: hidden;
          background: #f8fafc; /* Empty state background */
          z-index: 5; /* Behind the ring */
          box-shadow: inset 0 2px 10px rgba(0,0,0,0.05);
        }

        .hydration-fill {
          position: absolute;
          bottom: 0; left: 0; right: 0;
          background: linear-gradient(to top, #bae6fd 0%, #e0f2fe 100%);
          width: 100%;
          transition: height 1.2s cubic-bezier(0.4, 0, 0.2, 1);
          /* Optional: Add a subtle wave animation to the top edge if desired, 
             but prompt asked for simple filling */
          border-top: 1px solid rgba(255,255,255,0.5);
        }

        .glass-shine {
          position: absolute;
          top: 5%; left: 10%; right: 10%; height: 40%;
          border-radius: 50%;
          background: linear-gradient(180deg, rgba(255,255,255,0.9) 0%, rgba(255,255,255,0) 100%);
          opacity: 0.7;
          pointer-events: none;
        }

        /* --- Labels & Indicator --- */
        .ring-label {
          position: absolute;
          transform: translate(-50%, -50%);
          font-size: 10px;
          font-weight: 700;
          color: #94a3b8;
          letter-spacing: 0.5px;
        }

        .indicator-dot {
          position: absolute;
          width: 24px; height: 24px;
          transform: translate(-50%, -50%);
          background: #ffffff;
          border: 4px solid #3b82f6; /* Matches gradient start */
          border-radius: 50%;
          z-index: 20;
          box-shadow: 0 2px 5px rgba(0,0,0,0.2);
          transition: left 0.1s linear, top 0.1s linear, opacity 0.3s;
        }

        /* --- Typography --- */
        .center-content {
          position: absolute;
          top: 50%; left: 50%;
          transform: translate(-50%, -50%);
          text-align: center;
          z-index: 30;
          display: flex; flex-direction: column; align-items: center;
        }

        .score-val {
          font-size: 56px;
          font-weight: 700;
          color: #0f172a; /* Dark text for contrast */
          line-height: 1;
          letter-spacing: -2px;
        }

        .score-sub {
          font-size: 11px;
          font-weight: 700;
          color: #94a3b8;
          text-transform: uppercase;
          margin-top: 4px;
        }

        .score-title {
          display: flex; align-items: center; justify-content: center;
          font-size: 13px;
          font-weight: 600;
          color: #64748b;
          margin-top: 2px;
        }

        .hydration-stat {
          margin-top: 12px;
          display: flex; align-items: center; gap: 4px;
          font-size: 11px;
          font-weight: 700;
          color: #0284c7; /* Sky blue text */
          background: rgba(255,255,255,0.6);
          padding: 4px 8px;
          border-radius: 12px;
          box-shadow: 0 1px 2px rgba(0,0,0,0.05);
          backdrop-filter: blur(2px);
        }
        
        .drop-icon { fill: #0ea5e9; color: #0ea5e9; }
      `}</style>
		</div>
	);
}
