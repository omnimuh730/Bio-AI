import React from "react";
import Header from "./dashboard/Header";
import { FiCamera, FiX, FiSearch, FiMaximize } from "react-icons/fi";
import { FiImage } from "react-icons/fi";

// Mock camera feed using a static image for now, or just a dark background
// In a real mobile app this would be a CameraPreview widget
// Since this is web-based, we'll simulate a camera interface

export default function Capture() {
	const [mode, setMode] = React.useState("camera"); // camera | barcode | search

	return (
		<div className="capture-root">
			{/* Simulated Camera Feed Background */}
			<div className="camera-view">
				<div className="camera-overlay">
					{/* Top Controls */}
					<div className="top-controls">
						<button className="icon-btn">
							<FiX size={24} />
						</button>
						<div className="mode-pill">AI Vision Alpha</div>
						<button className="icon-btn">
							<FiImage size={24} />
						</button>
					</div>

					{/* Reticle / Gyro Guide */}
					<div className="reticle-container">
						<div className="reticle-corners"></div>
						<div className="reticle-center">+</div>
						<div className="pitch-indicator">
							<div
								className="pitch-bubble"
								style={{ transform: "translateY(-10px)" }}
							></div>
						</div>
						<div className="hint-text">Hold steady at 45°</div>
					</div>

					{/* Bottom Controls */}
					<div className="bottom-controls">
						<div className="mode-switcher">
							<button
								onClick={() => setMode("barcode")}
								className={mode === "barcode" ? "active" : ""}
							>
								Barcode
							</button>
							<button
								onClick={() => setMode("camera")}
								className={mode === "camera" ? "active" : ""}
							>
								Camera
							</button>
							<button
								onClick={() => setMode("search")}
								className={mode === "search" ? "active" : ""}
							>
								Search
							</button>
						</div>

						<div className="shutter-row">
							<button className="mini-btn">
								<FiSearch />
							</button>
							<button className="shutter-btn">
								<div className="shutter-inner"></div>
							</button>
							<button className="mini-btn">
								<FiMaximize />
							</button>
						</div>
					</div>
				</div>
				{/* Background image to simulate "see-through" */}
				<img
					src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80"
					className="camera-feed-img"
					alt="camera feed"
				/>
			</div>

			<style>{`
				.capture-root {
					height: 100vh;
					background: #000;
					color: white;
					position: relative;
					overflow: hidden;
				}
				.camera-view {
					width: 100%;
					height: 100%;
					position: relative;
				}
				.camera-feed-img {
					width: 100%;
					height: 100%;
					object-fit: cover;
					opacity: 0.6; /* Dim it a bit to show UI clearly */
				}
				.camera-overlay {
					position: absolute;
					inset: 0;
					z-index: 10;
					display: flex;
					flex-direction: column;
					justify-content: space-between;
					padding-top: 16px; 
					padding-bottom: 32px;
				}
				
				.top-controls {
					display: flex;
					justify-content: space-between;
					padding: 16px 20px;
					align-items: center;
				}
				.icon-btn {
					background: rgba(0,0,0,0.3);
					border: none;
					color: white;
					width: 40px; 
					height: 40px;
					border-radius: 50%;
					display: flex;
					align-items: center;
					justify-content: center;
					backdrop-filter: blur(4px);
				}
				.mode-pill {
					background: rgba(0,0,0,0.3);
					padding: 6px 14px;
					border-radius: 20px;
					font-size: 12px;
					font-weight: 600;
					backdrop-filter: blur(4px);
				}

				.reticle-container {
					flex: 1;
					display: flex;
					flex-direction: column;
					align-items: center;
					justify-content: center;
					position: relative;
				}
				.reticle-corners {
					width: 240px;
					height: 240px;
					border: 2px solid rgba(255,255,255,0.3);
					border-radius: 20px;
					position: relative;
				}
				.reticle-corners::after {
					content: '';
					position: absolute;
					inset: -2px;
					border: 2px solid transparent;
					/* Simulated corners with gradients or borders would go here */
				}
				.pitch-indicator {
					width: 6px;
					height: 60px;
					background: rgba(255,255,255,0.2);
					border-radius: 3px;
					margin-top: 20px;
					position: relative;
				}
				.pitch-bubble {
					width: 10px;
					height: 10px;
					background: #4ade80; /* Green alignment */
					border-radius: 50%;
					position: absolute;
					left: -2px;
					top: 50%;
				}
				.hint-text {
					margin-top: 12px;
					font-size: 13px;
					text-shadow: 0 2px 4px rgba(0,0,0,0.5);
					font-weight: 600;
				}
				
				.bottom-controls {
					display: flex;
					flex-direction: column;
					gap: 24px;
					padding-bottom: 30px; 
					/* Space for BottomNav, although capture usually hides it or overlays it */
					/* In this design, we'll keep it visible or let Home manage it */
				}
				.mode-switcher {
					display: flex;
					justify-content: center;
					gap: 20px;
				}
				.mode-switcher button {
					background: none;
					border: none;
					color: rgba(255,255,255,0.6);
					font-size: 13px;
					font-weight: 600;
					text-transform: uppercase;
					letter-spacing: 0.5px;
					padding: 4px 8px;
				}
				.mode-switcher button.active {
					color: #ffb199; /* Brand accent */
					color: white;
					background: rgba(255,255,255,0.2);
					border-radius: 12px;
				}
				
				.shutter-row {
					display: flex;
					justify-content: space-around;
					align-items: center;
					padding: 0 40px;
				}
				.shutter-btn {
					width: 72px;
					height: 72px;
					border-radius: 50%;
					border: 4px solid white;
					background: transparent;
					padding: 4px;
					cursor: pointer;
				}
				.shutter-inner {
					width: 100%;
					height: 100%;
					background: white;
					border-radius: 50%;
					transition: transform 0.1s;
				}
				.shutter-btn:active .shutter-inner {
					transform: scale(0.9);
				}
				.mini-btn {
					width: 44px;
					height: 44px;
					border-radius: 50%;
					background: rgba(255,255,255,0.2);
					border: none;
					color: white;
					display: flex;
					align-items: center;
					justify-content: center;
				}
			`}</style>
		</div>
	);
}
