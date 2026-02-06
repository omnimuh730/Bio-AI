import React from "react";
import { FiZap, FiRefreshCw, FiPlusCircle } from "react-icons/fi";

const suggestion = {
	time: "LUNCH - 12:30 PM",
	tag: "Anti-Stress",
	title: "Magnesium Power Bowl",
	meta: "450 kcal - 22g Protein - GF",
	img: "https://images.unsplash.com/photo-1604908177522-3b1b6c7a9908?auto=format&fit=crop&w=100&q=80",
};

export default function AISuggestion() {
	return (
		<div className="card ai-suggestion">
			<div className="meta">
				{suggestion.time}{" "}
				<span className="badge">
					<FiZap /> {suggestion.tag}
				</span>
			</div>
			<div className="ai-row">
				<img src={suggestion.img} alt="meal" />
				<div className="ai-info">
					<div className="title">{suggestion.title}</div>
					<div className="sub">{suggestion.meta}</div>
					<div className="why">Why this? ▾</div>
				</div>
			</div>
			<div className="ai-actions">
				<button className="repeat">
					<FiRefreshCw />
				</button>
				<button className="eat">
					<FiPlusCircle /> Eat This (450 kcal)
				</button>
			</div>
		</div>
	);
}
