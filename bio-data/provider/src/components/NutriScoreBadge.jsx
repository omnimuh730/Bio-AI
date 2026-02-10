import React from "react";
import { NutriScore } from "../types";
import { NUTRI_SCORE_COLORS } from "../constants";

const NutriScoreBadge = ({ score, size = "md" }) => {
	const sizeClasses = {
		sm: "w-6 h-6 text-xs",
		md: "w-10 h-10 text-lg",
		lg: "w-16 h-16 text-2xl",
	};

	return (
		<div
			className={`flex items-center justify-center rounded-lg font-bold text-white shadow-sm ${NUTRI_SCORE_COLORS[score]} ${sizeClasses[size]}`}
		>
			{score}
		</div>
	);
};

export default NutriScoreBadge;
