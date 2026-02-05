import React, { useEffect } from "react";
import "../splash.css";

export default function Splash({ onFinish }) {
	useEffect(() => {
		const id = setTimeout(() => {
			document.body.classList.add("splash-hidden");
			if (typeof onFinish === "function") onFinish();
		}, 1800);
		return () => clearTimeout(id);
	}, [onFinish]);

	return (
		<div className="splash-inner">
			<div className="splash-card">
				<svg
					className="splash-logo"
					viewBox="0 0 64 64"
					xmlns="http://www.w3.org/2000/svg"
					aria-hidden
				>
					<g
						fill="none"
						stroke="white"
						strokeWidth="3"
						strokeLinecap="round"
						strokeLinejoin="round"
					>
						<path d="M20 8v28" />
						<path d="M16 8c0 6 8 6 8 0" />
						<path d="M28 8v28" />
						<path d="M36 10c4 0 6 2 6 8v12c0 6-4 10-10 10h-4" />
					</g>
				</svg>
				<div className="splash-title">Eatsy</div>
			</div>
		</div>
	);
}
