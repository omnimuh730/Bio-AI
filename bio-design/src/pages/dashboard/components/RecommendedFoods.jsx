import React, { useRef, useState, useEffect } from "react";
import { FiChevronLeft, FiHeart, FiPlus } from "react-icons/fi";

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
		desc: "Fresh ingredients • 350g",
		calories: `${200 + (idx % 5) * 50} kcal`,
		price: `$${(5 + (idx % 10)).toFixed(2)}`,
		img: `https://picsum.photos/seed/${cat}-${idx}/400/300`, // Higher res for retina
	};
}

export default function RecommendedFoods({ onBack }) {
	const [active, setActive] = useState(0);
	const [items, setItems] = useState(() =>
		CATEGORIES.map((c) =>
			Array.from({ length: 6 }, (_, i) => makeItem(c, i)),
		),
	);
	const [loading, setLoading] = useState(false);

	// Refs for gestures and scrolling
	const touchStartX = useRef(0);
	const touchStartY = useRef(0);
	const containerRef = useRef(null);
	const tabsRef = useRef(null);

	// --- Scroll Active Tab into View ---
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

	// --- Infinite Scroll Logic ---
	function loadMoreFor(index) {
		if (loading) return;
		setLoading(true);

		// Simulate network delay
		setTimeout(() => {
			setItems((prev) => {
				const copy = [...prev]; // Shallow copy array
				const currentList = copy[index];
				const nextItems = Array.from({ length: 6 }, (_, i) =>
					makeItem(CATEGORIES[index], currentList.length + i),
				);
				copy[index] = [...currentList, ...nextItems];
				return copy;
			});
			setLoading(false);
		}, 1200);
	}

	function onScrollPanel(e) {
		const el = e.target;
		// Trigger load slightly before bottom (150px)
		if (el.scrollTop + el.clientHeight >= el.scrollHeight - 150) {
			loadMoreFor(active);
		}
	}

	// --- Swipe Logic (Horizontal Only) ---
	function onTouchStart(e) {
		touchStartX.current = e.touches[0].clientX;
		touchStartY.current = e.touches[0].clientY;
	}

	function onTouchEnd(e) {
		const dx = e.changedTouches[0].clientX - touchStartX.current;
		const dy = e.changedTouches[0].clientY - touchStartY.current;

		// Only trigger swipe if horizontal movement is dominant
		if (Math.abs(dx) > Math.abs(dy)) {
			if (dx > 70 && active > 0) setActive((a) => a - 1);
			else if (dx < -70 && active < CATEGORIES.length - 1)
				setActive((a) => a + 1);
		}
	}

	// --- Long Press Logic for Cards ---
	const handleLongPress = (item) => {
		// In a real app, this might open a quick-add menu or trigger haptics
		if (navigator.vibrate) navigator.vibrate(50);
		alert(`Quick Action: Added ${item.title} to Favorites!`);
	};

	return (
		<div className="rec-root">
			{/* 1. Glassmorphism Sticky Header */}
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

				{/* Scrollable Pills */}
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

			{/* 2. Swipeable Container */}
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
										onLongPress={() =>
											handleLongPress(item)
										}
									/>
								))}

								{/* Skeleton Loaders (Visual Placeholder) */}
								{loading && catIdx === active && (
									<>
										<SkeletonCard />
										<SkeletonCard />
									</>
								)}
							</div>

							{/* Bottom Spacer for safe scrolling */}
							<div style={{ height: 100 }} />
						</div>
					))}
				</div>
			</div>

			<style>{`
        /* --- Layout --- */
        .rec-root {
          position: fixed; inset: 0;
          background: #f8fafc;
          display: flex; flex-direction: column;
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
          color: #1e293b;
        }

        /* --- Header --- */
        .rec-header {
          position: relative; z-index: 20;
          background: rgba(255, 255, 255, 0.85);
          backdrop-filter: blur(12px);
          border-bottom: 1px solid rgba(0,0,0,0.05);
          padding-bottom: 12px;
          box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        }

        .rec-top-bar {
          display: flex; align-items: center;
          padding: 16px 20px;
          height: 60px;
        }

        .rec-top-bar h1 {
          font-size: 20px; font-weight: 800; margin-left: 16px;
          background: linear-gradient(135deg, #1e293b 0%, #475569 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
        }

        .spacer { flex: 1; }

        .icon-btn {
          border: none; background: transparent;
          width: 40px; height: 40px;
          display: flex; align-items: center; justify-content: center;
          border-radius: 50%;
          cursor: pointer;
          color: #334155;
          transition: background 0.2s;
        }
        .icon-btn:active { background: rgba(0,0,0,0.05); }

        .profile-btn img {
          width: 32px; height: 32px; border-radius: 50%;
          border: 2px solid #fff;
          box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        /* --- Tabs --- */
        .rec-tabs-wrapper {
          display: flex; gap: 12px;
          overflow-x: auto;
          padding: 0 20px;
          scrollbar-width: none; /* Firefox */
        }
        .rec-tabs-wrapper::-webkit-scrollbar { display: none; }

        .rec-tab {
          flex: 0 0 auto;
          padding: 8px 20px;
          border-radius: 24px;
          border: none;
          font-size: 14px; font-weight: 600;
          background: transparent;
          color: #64748b;
          transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        
        .rec-tab.active {
          background: #3b82f6;
          color: #fff;
          box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
          transform: scale(1.05);
        }

        /* --- Viewport & Slider --- */
        .rec-viewport {
          flex: 1;
          position: relative;
          overflow: hidden;
        }
        
        .rec-slider {
          display: flex;
          width: 100%; height: 100%;
          transition: transform 0.5s cubic-bezier(0.2, 0.8, 0.2, 1);
          will-change: transform;
        }

        .rec-panel {
          flex: 0 0 100%;
          width: 100%;
          height: 100%;
          overflow-y: auto;
          -webkit-overflow-scrolling: touch;
          padding: 20px;
          box-sizing: border-box;
        }

        /* --- Grid --- */
        .rec-grid {
          display: grid;
          grid-template-columns: repeat(2, 1fr);
          gap: 16px;
          padding-bottom: 40px;
        }

        @media (min-width: 600px) {
           .rec-grid { grid-template-columns: repeat(3, 1fr); }
        }

        /* --- Food Card Style --- */
        .food-card {
          position: relative;
          background: #fff;
          border-radius: 20px;
          overflow: hidden;
          box-shadow: 0 10px 15px -3px rgba(0,0,0,0.05), 0 4px 6px -2px rgba(0,0,0,0.02);
          transition: transform 0.2s, box-shadow 0.2s;
          user-select: none;
          /* GPU accel for smooth gesture animation */
          transform: translateZ(0); 
        }

        .food-card:active {
          transform: scale(0.96);
        }

        .img-wrapper {
          position: relative;
          width: 100%;
          padding-top: 85%; /* Aspect Ratio */
        }
        
        .img-wrapper img {
          position: absolute; inset: 0;
          width: 100%; height: 100%;
          object-fit: cover;
        }

        /* Gradient overlay for text readability if over image */
        .card-badge {
          position: absolute; top: 10px; right: 10px;
          background: rgba(255,255,255,0.9);
          backdrop-filter: blur(4px);
          padding: 4px 8px;
          border-radius: 8px;
          font-size: 10px; font-weight: 700;
          color: #3b82f6;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .card-content {
          padding: 12px;
        }

        .card-title {
          font-size: 15px; font-weight: 700;
          margin-bottom: 4px;
          white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }

        .card-desc {
          font-size: 11px; color: #94a3b8;
          margin-bottom: 8px;
        }

        .card-footer {
          display: flex; align-items: center; justify-content: space-between;
        }
        
        .card-price {
          font-size: 14px; font-weight: 800; color: #334155;
        }
        
        .add-btn {
          width: 28px; height: 28px;
          border-radius: 50%;
          background: #3b82f6;
          color: white;
          border: none;
          display: flex; align-items: center; justify-content: center;
          box-shadow: 0 4px 10px rgba(59, 130, 246, 0.4);
        }

        /* --- Skeleton --- */
        .skeleton-card {
          background: #fff; border-radius: 20px; 
          overflow: hidden;
          padding: 10px;
        }
        .sk-img {
          width: 100%; height: 120px; 
          background: #e2e8f0; border-radius: 14px; margin-bottom: 10px;
          animation: pulse 1.5s infinite ease-in-out;
        }
        .sk-line {
          height: 10px; background: #e2e8f0; border-radius: 5px;
          margin-bottom: 6px;
          animation: pulse 1.5s infinite ease-in-out;
          width: 80%;
        }
        .sk-line.short { width: 50%; }

        @keyframes pulse {
          0% { opacity: 0.6; }
          50% { opacity: 1; }
          100% { opacity: 0.6; }
        }
      `}</style>
		</div>
	);
}

// --- Sub-components for cleaner code ---

function FoodCard({ item, onLongPress }) {
	// Long press hook implementation
	const timerRef = useRef(null);

	const startPress = () => {
		timerRef.current = setTimeout(() => {
			onLongPress();
		}, 600); // 600ms long press
	};

	const endPress = () => {
		if (timerRef.current) {
			clearTimeout(timerRef.current);
			timerRef.current = null;
		}
	};

	return (
		<div
			className="food-card"
			onTouchStart={startPress}
			onTouchEnd={endPress}
			onMouseDown={startPress}
			onMouseUp={endPress}
			onMouseLeave={endPress}
		>
			<div className="img-wrapper">
				<img src={item.img} alt={item.title} loading="lazy" />
				<div className="card-badge">{item.calories}</div>
			</div>
			<div className="card-content">
				<div className="card-title">{item.title}</div>
				<div className="card-desc">{item.desc}</div>
				<div className="card-footer">
					<span className="card-price">{item.price}</span>
					<button className="add-btn">
						<FiPlus />
					</button>
				</div>
			</div>
		</div>
	);
}

function SkeletonCard() {
	return (
		<div className="skeleton-card">
			<div className="sk-img"></div>
			<div className="sk-line"></div>
			<div className="sk-line short"></div>
		</div>
	);
}
