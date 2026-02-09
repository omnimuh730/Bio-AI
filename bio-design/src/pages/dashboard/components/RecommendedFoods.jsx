import React, { useRef, useState, useEffect } from "react";
import { FiChevronLeft, FiPlus, FiX, FiCheck } from "react-icons/fi";

const CATEGORIES = [
	"Sandwiches",
	"Snacks",
	"Milk",
	"Fruits",
	"Bowls",
	"Salads",
	"Desserts",
	"Drinks",
];

// --- Mock Data Generator ---
function makeItem(cat, idx) {
	return {
		id: `${cat}-${Date.now()}-${idx}`,
		title: `${cat} Deluxe ${idx + 1}`,
		desc: "A premium selection of organic ingredients, carefully sourced for maximum freshness and flavor.",
		calories: 200 + (idx % 5) * 50,
		macros: {
			p: 12 + (idx % 5),
			c: 24 + (idx % 8),
			f: 8 + (idx % 3),
		},
		img: `https://picsum.photos/seed/${cat}-${idx}/500/500`, // Square-ish high res
	};
}

export default function RecommendedFoods({ onBack }) {
	const [active, setActive] = useState(0);
	const [items, setItems] = useState(() =>
		CATEGORIES.map((c) =>
			Array.from({ length: 12 }, (_, i) => makeItem(c, i)),
		),
	);
	const [loading, setLoading] = useState(false);
	const [selectedItem, setSelectedItem] = useState(null); // For Modal

	// Refs
	const touchStartX = useRef(0);
	const touchStartY = useRef(0);
	const containerRef = useRef(null);
	const tabsRef = useRef(null);

	// --- Scroll Tab into View ---
	useEffect(() => {
		if (tabsRef.current) {
			const tabNode = tabsRef.current.children[active];
			if (tabNode) {
				tabNode.scrollIntoView({
					behavior: "smooth",
					block: "nearest",
					inline: "center",
				});
			}
		}
	}, [active]);

	// --- Infinite Scroll ---
	function loadMoreFor(index) {
		if (loading) return;
		setLoading(true);
		setTimeout(() => {
			setItems((prev) => {
				const copy = [...prev];
				const currentList = copy[index];
				const nextItems = Array.from({ length: 6 }, (_, i) =>
					makeItem(CATEGORIES[index], currentList.length + i),
				);
				copy[index] = [...currentList, ...nextItems];
				return copy;
			});
			setLoading(false);
		}, 1000);
	}

	function onScrollPanel(e) {
		const el = e.target;
		if (el.scrollTop + el.clientHeight >= el.scrollHeight - 100) {
			loadMoreFor(active);
		}
	}

	// --- Swipe Logic ---
	function onTouchStart(e) {
		touchStartX.current = e.touches[0].clientX;
		touchStartY.current = e.touches[0].clientY;
	}

	function onTouchEnd(e) {
		const dx = e.changedTouches[0].clientX - touchStartX.current;
		const dy = e.changedTouches[0].clientY - touchStartY.current;
		if (Math.abs(dx) > Math.abs(dy) && Math.abs(dx) > 60) {
			if (dx > 0 && active > 0) setActive((a) => a - 1);
			else if (dx < 0 && active < CATEGORIES.length - 1)
				setActive((a) => a + 1);
		}
	}

	return (
		<div className="rec-root">
			{/* --- Header --- */}
			<header className="rec-header">
				<div className="rec-top-bar">
					<button className="icon-btn" onClick={onBack}>
						<FiChevronLeft size={24} />
					</button>
					<h1>Discover</h1>
					<div className="spacer" />
					<button className="icon-btn profile-btn">
						<img
							src="https://i.pravatar.cc/100?img=33"
							alt="User"
						/>
					</button>
				</div>
				<div className="rec-tabs-wrapper" ref={tabsRef}>
					{CATEGORIES.map((cat, idx) => (
						<button
							key={cat}
							className={`rec-tab ${idx === active ? "active" : ""}`}
							onClick={() => setActive(idx)}
						>
							{cat}
						</button>
					))}
				</div>
			</header>

			{/* --- Main Slider Viewport --- */}
			<div
				className="rec-viewport"
				onTouchStart={onTouchStart}
				onTouchEnd={onTouchEnd}
			>
				<div
					className="rec-slider"
					style={{ transform: `translateX(-${active * 100}%)` }}
				>
					{items.map((categoryItems, catIdx) => (
						<div
							key={catIdx}
							className="rec-panel"
							onScroll={onScrollPanel}
						>
							<div className="rec-grid">
								{categoryItems.map((item) => (
									<FoodCard
										key={item.id}
										item={item}
										onClick={() => setSelectedItem(item)}
									/>
								))}
								{loading && catIdx === active && (
									<SkeletonGrid />
								)}
							</div>
							<div style={{ height: 100 }} />
						</div>
					))}
				</div>
			</div>

			{/* --- Detail Modal --- */}
			{selectedItem && (
				<FoodModal
					item={selectedItem}
					onClose={() => setSelectedItem(null)}
				/>
			)}

			<style>{`
        /* Global Reset */
        .rec-root {
          position: fixed; inset: 0;
          background: #f8fafc;
          display: flex; flex-direction: column;
          font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
          color: #1e293b;
        }

        /* Header */
        .rec-header {
          position: relative; z-index: 20;
          background: rgba(255, 255, 255, 0.9);
          backdrop-filter: blur(20px);
          padding-bottom: 12px;
        }
        .rec-top-bar { display: flex; align-items: center; padding: 12px 20px; height: 56px; }
        .rec-top-bar h1 { font-size: 22px; font-weight: 800; margin-left: 12px; letter-spacing: -0.5px; color: #0f172a; }
        .spacer { flex: 1; }
        .icon-btn { border: none; background: transparent; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; border-radius: 50%; cursor: pointer; color: #334155; }
        .profile-btn img { width: 34px; height: 34px; border-radius: 50%; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }

        /* Tabs */
        .rec-tabs-wrapper { display: flex; gap: 8px; overflow-x: auto; padding: 0 20px; scrollbar-width: none; }
        .rec-tabs-wrapper::-webkit-scrollbar { display: none; }
        .rec-tab {
          padding: 8px 16px; border-radius: 20px; border: none;
          font-size: 13px; font-weight: 600; background: transparent; color: #94a3b8;
          white-space: nowrap; transition: all 0.3s ease;
        }
        .rec-tab.active { background: #0f172a; color: #fff; box-shadow: 0 4px 10px rgba(15, 23, 42, 0.3); }

        /* Slider/Grid */
        .rec-viewport { flex: 1; position: relative; overflow: hidden; }
        .rec-slider { display: flex; width: 100%; height: 100%; transition: transform 0.5s cubic-bezier(0.2, 0.8, 0.2, 1); will-change: transform; }
        .rec-panel { flex: 0 0 100%; width: 100%; height: 100%; overflow-y: auto; -webkit-overflow-scrolling: touch; padding: 20px; box-sizing: border-box; }
        .rec-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 14px; }
        @media (min-width: 600px) { .rec-grid { grid-template-columns: repeat(3, 1fr); } }

        /* --- COMPACT LUXURY CARD --- */
        .food-card {
          background: #fff;
          border-radius: 20px;
          overflow: hidden;
          box-shadow: 0 4px 15px rgba(0,0,0,0.03);
          transition: transform 0.15s ease-out;
          position: relative;
          cursor: pointer;
        }
        .food-card:active { transform: scale(0.96); }

        .card-image-wrap {
          position: relative;
          width: 100%;
          padding-top: 100%; /* 1:1 Aspect Ratio */
          background: #e2e8f0;
        }
        .card-image-wrap img {
          position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover;
        }

        /* Overlay Gradient for text legibility if needed, mostly clean though */
        .card-overlay {
          position: absolute; inset: 0;
          background: linear-gradient(to bottom, rgba(0,0,0,0) 60%, rgba(0,0,0,0.05) 100%);
        }

        /* Floating Badge Top Left */
        .card-cal-badge {
          position: absolute; top: 10px; left: 10px;
          background: rgba(255,255,255,0.85); backdrop-filter: blur(4px);
          padding: 4px 8px; border-radius: 10px;
          font-size: 10px; font-weight: 700; color: #0f172a;
          box-shadow: 0 2px 6px rgba(0,0,0,0.08);
        }

        /* Floating Action Button Bottom Right */
        .card-fab {
          position: absolute; bottom: 8px; right: 8px;
          width: 32px; height: 32px;
          border-radius: 12px;
          background: rgba(15, 23, 42, 0.9);
          backdrop-filter: blur(4px);
          color: white; border: none;
          display: flex; align-items: center; justify-content: center;
          box-shadow: 0 4px 12px rgba(0,0,0,0.2);
          z-index: 2;
        }

        .card-details {
          padding: 10px 12px;
        }
        .card-title {
          font-size: 14px; font-weight: 700; color: #1e293b;
          white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .card-sub {
          font-size: 11px; font-weight: 500; color: #94a3b8; margin-top: 2px;
        }

        /* --- SKELETON --- */
        .sk-card { background: #fff; border-radius: 20px; overflow: hidden; }
        .sk-img { padding-top: 100%; background: #f1f5f9; animation: pulse 1.5s infinite; }
        .sk-txt { height: 10px; background: #f1f5f9; margin: 10px 12px; border-radius: 5px; width: 60%; animation: pulse 1.5s infinite; }
        @keyframes pulse { 50% { opacity: 0.6; } }

        /* --- LUXURY MODAL --- */
        .modal-overlay {
          position: fixed; inset: 0; z-index: 100;
          background: rgba(0,0,0,0.3); backdrop-filter: blur(8px);
          display: flex; align-items: flex-end; justify-content: center;
          animation: fadeIn 0.3s ease;
        }
        
        .modal-card {
          width: 100%; max-width: 500px;
          background: #fff;
          border-radius: 32px 32px 0 0;
          overflow: hidden;
          box-shadow: 0 -10px 40px rgba(0,0,0,0.1);
          animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1);
          display: flex; flex-direction: column;
          max-height: 90vh;
        }

        .modal-hero {
          position: relative;
          height: 280px;
        }
        .modal-hero img { width: 100%; height: 100%; object-fit: cover; }
        
        .modal-close {
          position: absolute; top: 16px; right: 16px;
          width: 36px; height: 36px; background: rgba(0,0,0,0.2);
          backdrop-filter: blur(4px); border-radius: 50%; border: none;
          color: white; display: flex; align-items: center; justify-content: center;
          cursor: pointer;
        }

        .modal-body {
          padding: 24px;
          overflow-y: auto;
        }
        
        .modal-title { font-size: 24px; font-weight: 800; color: #0f172a; margin-bottom: 8px; line-height: 1.1; }
        .modal-cal { font-size: 16px; font-weight: 600; color: #3b82f6; margin-bottom: 20px; }
        
        .modal-desc {
          font-size: 14px; line-height: 1.6; color: #64748b; margin-bottom: 24px;
        }

        .macros-row {
          display: flex; gap: 12px; margin-bottom: 30px;
        }
        .macro-chip {
          flex: 1; background: #f8fafc; padding: 12px; border-radius: 16px;
          text-align: center; border: 1px solid #e2e8f0;
        }
        .macro-val { font-size: 16px; font-weight: 800; color: #334155; display: block; }
        .macro-lbl { font-size: 10px; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.5px; }

        .modal-cta {
          width: 100%; padding: 16px;
          background: #0f172a; color: white; border: none;
          border-radius: 20px; font-size: 16px; font-weight: 700;
          display: flex; align-items: center; justify-content: center; gap: 8px;
          box-shadow: 0 8px 20px rgba(15, 23, 42, 0.25);
          cursor: pointer; transition: transform 0.2s;
        }
        .modal-cta:active { transform: scale(0.98); }

        @keyframes slideUp { from { transform: translateY(100%); } to { transform: translateY(0); } }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
      `}</style>
		</div>
	);
}

// --- Compact Food Card ---
function FoodCard({ item, onClick }) {
	return (
		<div className="food-card" onClick={onClick}>
			<div className="card-image-wrap">
				<img src={item.img} alt={item.title} loading="lazy" />
				<div className="card-overlay" />

				{/* Floating Metadata */}
				<div className="card-cal-badge">{item.calories} kcal</div>

				{/* Integrated Action Button */}
				<button
					className="card-fab"
					onClick={(e) => {
						e.stopPropagation();
						alert("Quick Add!");
					}}
				>
					<FiPlus />
				</button>
			</div>

			<div className="card-details">
				<div className="card-title">{item.title}</div>
				<div className="card-sub">Perfect for lunch</div>
			</div>
		</div>
	);
}

// --- Skeleton Placeholder ---
function SkeletonGrid() {
	return (
		<>
			{[1, 2].map((i) => (
				<div className="sk-card" key={i}>
					<div className="sk-img" />
					<div className="sk-txt" />
				</div>
			))}
		</>
	);
}

// --- Luxury Modal Component ---
function FoodModal({ item, onClose }) {
	// Prevent background scroll
	useEffect(() => {
		document.body.style.overflow = "hidden";
		return () => (document.body.style.overflow = "");
	}, []);

	return (
		<div className="modal-overlay" onClick={onClose}>
			<div className="modal-card" onClick={(e) => e.stopPropagation()}>
				{/* Hero Image */}
				<div className="modal-hero">
					<img src={item.img} alt={item.title} />
					<button className="modal-close" onClick={onClose}>
						<FiX size={20} />
					</button>
				</div>

				{/* Content Body */}
				<div className="modal-body">
					<div className="modal-title">{item.title}</div>
					<div className="modal-cal">
						{item.calories} kcal · Healthy Choice
					</div>

					<p className="modal-desc">{item.desc}</p>

					{/* Nutrition Info */}
					<div className="macros-row">
						<div className="macro-chip">
							<span className="macro-val">{item.macros.p}g</span>
							<span className="macro-lbl">Protein</span>
						</div>
						<div className="macro-chip">
							<span className="macro-val">{item.macros.c}g</span>
							<span className="macro-lbl">Carbs</span>
						</div>
						<div className="macro-chip">
							<span className="macro-val">{item.macros.f}g</span>
							<span className="macro-lbl">Fat</span>
						</div>
					</div>

					<button
						className="modal-cta"
						onClick={() => {
							alert("Added!");
							onClose();
						}}
					>
						<FiCheck size={20} />
						Add to Diary
					</button>
				</div>
			</div>
		</div>
	);
}
