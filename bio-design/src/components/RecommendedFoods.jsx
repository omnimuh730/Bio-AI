import React from "react";
import "./dashboard/recommended.css";
import { FiChevronLeft } from "react-icons/fi";

const CATEGORIES = [
	"Sandwiches",
	"Snacks",
	"Milk",
	"Fruits",
	"Bowls",
	"Salads",
];

function makeItem(cat, idx) {
	return {
		id: `${cat}-${Date.now()}-${idx}`,
		title: `${cat} Item ${idx + 1}`,
		meta: `${200 + (idx % 5) * 50} kcal`,
		img: `https://picsum.photos/seed/${cat}-${idx}/160/120`,
	};
}

export default function RecommendedFoods({ onBack }) {
	const [active, setActive] = React.useState(0);
	const [items, setItems] = React.useState(() =>
		CATEGORIES.map((c) =>
			Array.from({ length: 8 }, (_, i) => makeItem(c, i)),
		),
	);
	const [loading, setLoading] = React.useState(false);
	const containerRef = React.useRef(null);
	const touchStartX = React.useRef(0);

	function loadMoreFor(index) {
		setLoading(true);
		setTimeout(() => {
			setItems((prev) => {
				const copy = prev.map((arr) => arr.slice());
				const nextItems = Array.from({ length: 8 }, (_, i) =>
					makeItem(CATEGORIES[index], arrLen(copy[index]) + i),
				);
				copy[index] = copy[index].concat(nextItems);
				return copy;
			});
			setLoading(false);
		}, 600);
	}

	function arrLen(arr) {
		return arr ? arr.length : 0;
	}

	function onTouchStart(e) {
		touchStartX.current = e.touches[0].clientX;
	}

	function onTouchEnd(e) {
		const dx = e.changedTouches[0].clientX - touchStartX.current;
		if (dx > 60 && active > 0) setActive((a) => a - 1);
		else if (dx < -60 && active < CATEGORIES.length - 1)
			setActive((a) => a + 1);
	}

	function onScrollPanel(e) {
		const el = e.target;
		if (
			el.scrollTop + el.clientHeight >= el.scrollHeight - 120 &&
			!loading
		) {
			loadMoreFor(active);
		}
	}

	return (
		<div className="recommended-root page-fade">
			<div className="recommended-header">
				<button
					className="back-button"
					onClick={onBack}
					aria-label="Back"
				>
					<FiChevronLeft />
				</button>
				<h2>Recommended Foods</h2>
			</div>

			<div className="category-tabs">
				{CATEGORIES.map((c, idx) => (
					<button
						key={c}
						className={`tab ${idx === active ? "active" : ""}`}
						onClick={() => setActive(idx)}
					>
						{c}
					</button>
				))}
			</div>

			<div
				className="panels-wrap"
				onTouchStart={onTouchStart}
				onTouchEnd={onTouchEnd}
			>
				<div
					className="panels"
					style={{ transform: `translateX(-${active * 100}%)` }}
				>
					{items.map((arr, idx) => (
						<div
							key={CATEGORIES[idx]}
							className="panel"
							onScroll={onScrollPanel}
							ref={idx === active ? containerRef : null}
						>
							<div className="grid">
								{arr.map((it) => (
									<div className="food-card" key={it.id}>
										<img src={it.img} alt="food" />
										<div className="food-title">
											{it.title}
										</div>
										<div className="food-meta">
											{it.meta}
										</div>
									</div>
								))}
							</div>
							{loading && idx === active && (
								<div className="loader">Loading more…</div>
							)}
						</div>
					))}
				</div>
			</div>
		</div>
	);
}
