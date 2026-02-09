import React from "react";
import { FiX, FiSearch, FiMaximize, FiImage } from "react-icons/fi";

// --- Dragunov (PSO-1) Style Reticle ---
const DragunovReticle = ({ inRange, angle }) => {
	// Color logic: Red (classic illuminated reticle) when active, dim when not aligned
	const activeColor = inRange ? "#ff0000" : "rgba(200, 0, 0, 0.4)";
	const glow = inRange
		? "drop-shadow(0px 0px 4px rgba(255,0,0,0.8))"
		: "none";

	return (
		<svg
			viewBox="0 0 400 600"
			style={{
				width: "100%",
				height: "100%",
				position: "absolute",
				top: 0,
				left: 0,
				pointerEvents: "none",
				zIndex: 20,
			}}
		>
			<defs>
				<filter id="glow-filter">
					<feGaussianBlur stdDeviation="2" result="coloredBlur" />
					<feMerge>
						<feMergeNode in="coloredBlur" />
						<feMergeNode in="SourceGraphic" />
					</feMerge>
				</filter>
			</defs>

			<g
				stroke={activeColor}
				fill="none"
				strokeWidth="1.5"
				style={{ transition: "stroke 0.3s ease", filter: glow }}
			>
				{/* --- 1. CENTER CHEVRONS (Aim Points) --- */}
				{/* Main Center Chevron */}
				<path d="M 190,300 L 200,290 L 210,300" strokeWidth="2" />
				{/* Lower Drop Chevrons */}
				<path d="M 195,330 L 200,325 L 205,330" opacity="0.7" />
				<path d="M 195,360 L 200,355 L 205,360" opacity="0.7" />
				{/* --- 2. HORIZONTAL SIZE RULERS (The "Immutable" Scales) --- */}
				{/* Assumed geometry: At 20" distance, fixed pixel widths represent real inches */}
				{/* 5 INCH RULER (Center) */}
				{/* Width calculated relative to viewbox */}
				<line x1="150" y1="300" x2="190" y2="300" />
				<line x1="210" y1="300" x2="250" y2="300" />
				<line x1="150" y1="295" x2="150" y2="305" /> {/* Tick Left */}
				<line x1="250" y1="295" x2="250" y2="305" /> {/* Tick Right */}
				<text
					x="260"
					y="305"
					fill={activeColor}
					fontSize="10"
					stroke="none"
					fontFamily="monospace"
				>
					5"
				</text>
				{/* 10 INCH RULER (Below) */}
				<line x1="100" y1="380" x2="300" y2="380" opacity="0.8" />
				<line x1="100" y1="375" x2="100" y2="385" />
				<line x1="300" y1="375" x2="300" y2="385" />
				<text
					x="310"
					y="385"
					fill={activeColor}
					fontSize="10"
					stroke="none"
					fontFamily="monospace"
				>
					10"
				</text>
				{/* 15 INCH RULER (Further Below) */}
				<line x1="50" y1="460" x2="350" y2="460" opacity="0.6" />
				<line x1="50" y1="455" x2="50" y2="465" />
				<line x1="350" y1="455" x2="350" y2="465" />
				<text
					x="360"
					y="465"
					fill={activeColor}
					fontSize="10"
					stroke="none"
					fontFamily="monospace"
				>
					15"
				</text>
				{/* --- 3. STADIAMETRIC RANGE CURVE (Right Side) --- */}
				{/* 
           In a real PSO-1, this measures a 1.7m human.
           Here, we define a curve that measures a 3-inch (standard bowl height).
           If the bowl fits under the curve, the distance is correct.
        */}
				<path
					d="M 320,300 Q 320,200 380,200"
					strokeDasharray="4,2"
					opacity="0.8"
				/>
				<line x1="320" y1="300" x2="380" y2="300" /> {/* Base Line */}
				<text
					x="330"
					y="280"
					fill={activeColor}
					fontSize="9"
					stroke="none"
					fontFamily="monospace"
				>
					BOWL
				</text>
				<text
					x="330"
					y="292"
					fill={activeColor}
					fontSize="9"
					stroke="none"
					fontFamily="monospace"
				>
					HEIGHT
				</text>
				<text
					x="355"
					y="215"
					fill={activeColor}
					fontSize="10"
					stroke="none"
					fontFamily="monospace"
				>
					REF
				</text>
				{/* --- 4. GYRO HORIZON LINE --- */}
				{/* This line tilts to show the user if they are holding phone level */}
				<g
					style={{
						transformOrigin: "200px 300px",
						transform: `rotate(${-(angle - 45) * 2}deg)`,
					}}
				>
					<line
						x1="20"
						y1="300"
						x2="140"
						y2="300"
						strokeWidth="1"
						strokeDasharray="2,2"
						opacity="0.5"
					/>
					<line
						x1="260"
						y1="300"
						x2="380"
						y2="300"
						strokeWidth="1"
						strokeDasharray="2,2"
						opacity="0.5"
					/>
				</g>
			</g>
		</svg>
	);
};

export default function Capture({ onClose }) {
	const [angle, setAngle] = React.useState(45);
	const [inRange, setInRange] = React.useState(true);
	const [flash, setFlash] = React.useState(false);

	// Simulated Gyro Logic
	React.useEffect(() => {
		let current = 40 + Math.random() * 10;
		setAngle(Math.round(current));
		const id = setInterval(() => {
			// Simulate hand shake
			let jitter = (Math.random() - 0.5) * 4;
			current = Math.max(0, Math.min(90, current + jitter));
			setAngle(Math.round(current));

			// Strict angle check for the reticle to "light up"
			setInRange(current >= 42 && current <= 48);
		}, 50);
		return () => clearInterval(id);
	}, []);

	function doCapture() {
		setFlash(true);
		setTimeout(() => setFlash(false), 300);
	}

	return (
		<div className="capture-root">
			<div className="camera-view">
				<div className="camera-overlay">
					{/* Top Header */}
					<div className="top-controls">
						<button
							className="icon-btn"
							onClick={() => onClose && onClose()}
						>
							<FiX size={24} />
						</button>
						<div className="tech-badge">
							<span className="dot"></span> RANGEFINDER ACTIVE
						</div>
						<button className="icon-btn">
							<FiImage size={24} />
						</button>
					</div>

					{/* RETICLE LAYER */}
					<div className="reticle-container">
						<DragunovReticle inRange={inRange} angle={angle} />

						{/* Status Text (HUD) */}
						<div className="hud-data">
							<div className="hud-row">
								<span className="label">PITCH</span>
								<span
									className={`value ${inRange ? "good" : "bad"}`}
								>
									{angle}°
								</span>
							</div>
							<div className="hud-row">
								<span className="label">DIST</span>
								<span className="value">CALIBRATING...</span>
							</div>
							<div className="hud-hint">
								{inRange ? ">> HOLD STEADY <<" : "TILT TO 45°"}
							</div>
						</div>
					</div>

					{/* Bottom Controls */}
					<div className="bottom-controls">
						{/* Instructional Hint */}
						<div className="instruction-toast">
							Align <b>5" / 10"</b> lines with food width.
							<br />
							Use side curve to verify distance.
						</div>

						<div className="shutter-row">
							<button className="mini-btn">
								<FiSearch />
							</button>
							<button className="shutter-btn" onClick={doCapture}>
								<div className="shutter-inner" />
							</button>
							<button className="mini-btn">
								<FiMaximize />
							</button>
						</div>
					</div>
				</div>

				{/* Background Feed */}
				<img
					src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80"
					className="camera-feed-img"
					alt="camera feed"
				/>
				{/* Flash Effect */}
				{flash && <div className="flash-overlay" />}

				{/* Vignette for Scope feel */}
				<div className="scope-vignette"></div>
			</div>

			<style>{`
        .capture-root { height: 100vh; background: #111; color: white; position: relative; overflow: hidden; font-family: 'Courier New', Courier, monospace; }
        
        .camera-view { width: 100%; height: 100%; position: relative; }
        .camera-feed-img { width: 100%; height: 100%; object-fit: cover; opacity: 0.8; filter: contrast(1.1) grayscale(0.2); }
        .scope-vignette { position: absolute; inset: 0; background: radial-gradient(circle, transparent 50%, rgba(0,0,0,0.8) 100%); pointer-events: none; z-index: 5; }
        
        .flash-overlay { position: absolute; inset: 0; background: white; z-index: 50; animation: fadeOut 0.2s forwards; }
        @keyframes fadeOut { to { opacity: 0; } }

        .camera-overlay { position: absolute; inset: 0; z-index: 10; display: flex; flex-direction: column; justify-content: space-between; }
        
        .top-controls { display: flex; justify-content: space-between; padding: 16px 20px; align-items: center; z-index: 30; }
        .icon-btn { background: rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.2); color: white; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
        
        .tech-badge { 
            background: rgba(0, 20, 0, 0.7); 
            border: 1px solid #33ff00; 
            color: #33ff00;
            padding: 4px 12px; 
            font-size: 10px; 
            letter-spacing: 1px;
            display: flex; 
            align-items: center; 
            gap: 6px;
        }
        .dot { width: 6px; height: 6px; background: #33ff00; border-radius: 50%; animation: pulse 1s infinite; }
        @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.3; } 100% { opacity: 1; } }

        .reticle-container { flex: 1; position: relative; width: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; }
        
        .hud-data {
            position: absolute;
            top: 20%;
            left: 20px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .hud-row { font-size: 12px; color: rgba(255,255,255,0.7); display: flex; gap: 8px; }
        .value { font-weight: bold; }
        .value.good { color: #33ff00; }
        .value.bad { color: #ff3333; }
        .hud-hint { margin-top: 8px; font-weight: bold; color: #ff3333; font-size: 14px; text-shadow: 0 0 5px black; }

        .bottom-controls { display: flex; flex-direction: column; gap: 20px; padding-bottom: 40px; align-items: center; z-index: 30; }
        
        .instruction-toast {
            background: rgba(0,0,0,0.6);
            border-left: 3px solid #ff3333;
            padding: 8px 16px;
            font-size: 11px;
            line-height: 1.4;
            max-width: 200px;
            text-align: center;
            color: #ddd;
        }

        .shutter-row { display: flex; gap: 40px; align-items: center; }
        .shutter-btn { width: 70px; height: 70px; border-radius: 50%; border: 2px solid rgba(255,255,255,0.5); background: rgba(0,0,0,0.3); padding: 4px; cursor: pointer; }
        .shutter-inner { width: 100%; height: 100%; border-radius: 50%; background: #ff3333; transition: transform 0.1s; }
        .shutter-btn:active .shutter-inner { transform: scale(0.9); }
        .mini-btn { background: none; border: none; color: rgba(255,255,255,0.7); font-size: 20px; }
      `}</style>
		</div>
	);
}
