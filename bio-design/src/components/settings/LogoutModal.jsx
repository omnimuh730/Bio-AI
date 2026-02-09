import React, { useEffect, useState } from "react";
import { FiLogOut, FiX } from "react-icons/fi";

export default function LogoutModal({ open, onClose }) {
	const [visible, setVisible] = useState(false);
	const [loggingOut, setLoggingOut] = useState(false);

	// Handle entry/exit animations
	useEffect(() => {
		if (open) {
			setVisible(true);
		} else {
			const timer = setTimeout(() => setVisible(false), 300); // Wait for exit anim
			return () => clearTimeout(timer);
		}
	}, [open]);

	if (!visible && !open) return null;

	const handleLogout = () => {
		setLoggingOut(true);
		// Simulate API call or cleanup
		setTimeout(() => {
			// Actually perform logout logic here (e.g., clear tokens)
			window.location.reload();
		}, 1500);
	};

	return (
		<div
			className={`logout-overlay ${open ? "active" : ""}`}
			onClick={onClose}
		>
			<style>{`
        .logout-overlay {
          position: fixed; inset: 0; z-index: 200;
          background: rgba(0, 0, 0, 0);
          backdrop-filter: blur(0px);
          display: flex; align-items: center; justify-content: center;
          transition: background 0.3s ease, backdrop-filter 0.3s ease;
          pointer-events: none;
        }
        .logout-overlay.active {
          background: rgba(0, 0, 0, 0.4);
          backdrop-filter: blur(8px);
          pointer-events: auto;
        }

        .logout-card {
          width: 85%; max-width: 320px;
          background: rgba(255, 255, 255, 0.95);
          border-radius: 28px;
          padding: 32px 24px;
          text-align: center;
          box-shadow: 0 20px 50px rgba(0,0,0,0.2);
          transform: scale(0.9) translateY(20px);
          opacity: 0;
          transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .logout-overlay.active .logout-card {
          transform: scale(1) translateY(0);
          opacity: 1;
        }

        .icon-bubble {
          width: 72px; height: 72px;
          background: linear-gradient(135deg, #fee2e2, #fecaca);
          color: #ef4444;
          border-radius: 50%;
          display: flex; align-items: center; justify-content: center;
          margin: 0 auto 20px auto;
          font-size: 32px;
          box-shadow: 0 10px 20px rgba(239, 68, 68, 0.15);
          animation: pulse-red 2s infinite;
        }

        @keyframes pulse-red {
          0% { box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.4); }
          70% { box-shadow: 0 0 0 15px rgba(239, 68, 68, 0); }
          100% { box-shadow: 0 0 0 0 rgba(239, 68, 68, 0); }
        }

        .modal-title {
          font-size: 20px; font-weight: 800; color: #1f2937;
          margin: 0 0 8px 0;
        }
        .modal-desc {
          font-size: 14px; color: #6b7280; line-height: 1.5;
          margin-bottom: 28px;
        }

        .modal-actions {
          display: flex; gap: 12px;
        }
        .btn-modal {
          flex: 1; padding: 14px; border-radius: 16px;
          font-weight: 700; font-size: 15px; border: none; cursor: pointer;
          transition: transform 0.1s;
        }
        .btn-modal:active { transform: scale(0.95); }
        
        .btn-cancel {
          background: #f3f4f6; color: #4b5563;
        }
        .btn-logout {
          background: linear-gradient(135deg, #ef4444, #dc2626);
          color: white;
          box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
          display: flex; align-items: center; justify-content: center; gap: 8px;
        }
        .btn-logout:disabled { opacity: 0.7; pointer-events: none; }

        .spinner {
          width: 16px; height: 16px;
          border: 2px solid rgba(255,255,255,0.3);
          border-top: 2px solid #fff;
          border-radius: 50%;
          animation: spin 0.8s infinite linear;
        }
        @keyframes spin { to { transform: rotate(360deg); } }

      `}</style>

			{/* Prevent clicks inside modal from closing it */}
			<div className="logout-card" onClick={(e) => e.stopPropagation()}>
				<div className="icon-bubble">
					<FiLogOut style={{ marginLeft: 4 }} />
				</div>

				<h3 className="modal-title">Log out?</h3>
				<p className="modal-desc">
					Are you sure you want to sign out? You will need to enter
					your credentials again.
				</p>

				<div className="modal-actions">
					<button
						className="btn-modal btn-cancel"
						onClick={onClose}
						disabled={loggingOut}
					>
						Cancel
					</button>
					<button
						className="btn-modal btn-logout"
						onClick={handleLogout}
						disabled={loggingOut}
					>
						{loggingOut ? (
							<>
								<div className="spinner" />
								<span>Bye...</span>
							</>
						) : (
							"Yes, Log Out"
						)}
					</button>
				</div>
			</div>
		</div>
	);
}
