import React, { useEffect } from "react";
import "./splash.css";

import { FiSearch } from "react-icons/fi";

export default function Splash({ onFinish }) {
	useEffect(() => {
		let finishId;
		const id = setTimeout(() => {
			document.body.classList.add("splash-hidden");
			finishId = setTimeout(() => {
				if (typeof onFinish === "function") onFinish();
			}, 420);
		}, 2200);

		return () => {
			clearTimeout(id);
			clearTimeout(finishId);
			document.body.classList.remove("splash-hidden");
		};
	}, [onFinish]);

	return (
		<div className="splash-full">
			<div className="search-bubble" aria-hidden>
				<FiSearch size={16} />
				<div className="bubble-text">Drag to search</div>
			</div>

			<div className="splash-center">
				<svg
					className="splash-logo"
					viewBox="0 0 64 64"
					xmlns="http://www.w3.org/2000/svg"
					aria-hidden
				>
					<g
						fill="none"
						stroke="rgba(255,255,255,0.9)"
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
