import React from "react";
import { FiArrowRight, FiZap } from "react-icons/fi";

export default function RecommendedCard({ onOpen }) {
	// Using a distinct image that pops against white
	const imgUrl =
		"https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=300&q=80";

	return (
		<div className="rec-card-split" onClick={onOpen}>
			<div className="rec-text-section">
				<div className="rec-top-badge">
					<span className="badge-highlight">Dinner Idea</span>
				</div>

				<h3 className="rec-title">Salmon & Beet Power Salad</h3>

				<div className="rec-meta-row">
					<div className="meta-pill">
						<FiZap size={14} className="icon-fire" />
						<span>420 kcal</span>
					</div>
					<div className="meta-dot">•</div>
					<span className="meta-text">High Protein</span>
				</div>
			</div>

			<div className="rec-visual-section">
				<div className="rec-image-wrapper">
					<img src={imgUrl} alt="Salmon Salad" />
				</div>
				<button className="rec-action-btn">
					<FiArrowRight />
				</button>
			</div>

			<style>{`
        .rec-card-split {
          background: white;
          border-radius: 24px;
          padding: 16px 16px 16px 20px;
          display: flex;
          align-items: center;
          justify-content: space-between;
          box-shadow: 0 10px 40px -10px rgba(0,0,0,0.08); /* Soft, deep shadow */
          border: 1px solid rgba(0,0,0,0.03);
          cursor: pointer;
          transition: transform 0.2s ease, box-shadow 0.2s ease;
          position: relative;
          overflow: visible; /* Allows button to overlap slightly if needed */
          margin-bottom: 20px;
        }
        
        .rec-card-split:active {
          transform: scale(0.98);
          box-shadow: 0 5px 15px -5px rgba(0,0,0,0.08);
        }

        /* --- Left Side: Text --- */
        .rec-text-section {
          flex: 1;
          padding-right: 15px;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }

        .rec-top-badge { margin-bottom: 8px; }
        .badge-highlight {
          background: #eff6ff; color: #3b82f6; /* Blue-ish tint */
          font-size: 10px; font-weight: 800; letter-spacing: 0.5px;
          text-transform: uppercase;
          padding: 4px 10px; border-radius: 10px;
        }

        .rec-title {
          font-size: 18px;
          font-weight: 800;
          color: #1e293b;
          margin: 0 0 10px 0;
          line-height: 1.3;
          letter-spacing: -0.5px;
        }

        .rec-meta-row {
          display: flex; align-items: center; gap: 8px;
        }

        .meta-pill {
          display: flex; align-items: center; gap: 4px;
          color: #f59e0b; /* Amber */
          font-weight: 700; font-size: 13px;
        }
        .icon-fire { fill: #f59e0b; } /* Filled icon style */
        
        .meta-dot { color: #cbd5e1; }
        .meta-text { color: #94a3b8; font-size: 12px; font-weight: 600; }

        /* --- Right Side: Image & Action --- */
        .rec-visual-section {
          position: relative;
          flex-shrink: 0;
        }

        .rec-image-wrapper {
          width: 90px;
          height: 90px;
          border-radius: 18px;
          overflow: hidden;
          box-shadow: 0 4px 12px rgba(0,0,0,0.1);
          transform: rotate(3deg); /* Slight tilt for 'awesome' feel */
          border: 2px solid white;
        }

        .rec-image-wrapper img {
          width: 100%; height: 100%; object-fit: cover;
        }

        .rec-action-btn {
          position: absolute;
          bottom: -8px;
          left: -12px;
          width: 36px; height: 36px;
          border-radius: 50%;
          background: #1e293b; color: white;
          border: 3px solid white;
          display: flex; align-items: center; justify-content: center;
          font-size: 18px;
          box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        }
      `}</style>
		</div>
	);
}
