import React, { useEffect, useRef, useState } from "react";
import "../boti.css";

export default function Boti() {
	const restaurants = [
		{
			name: "El rinconcito",
			img: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80",
			rating: "9,2",
			reviews: 70,
			desc: "Seasonal Spanish plates with citrus-forward seafood and rustic tapas.",
		},
		{
			name: "Burguer Town",
			img: "https://images.unsplash.com/photo-1550547660-d9450f859349?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80",
			rating: "7,2",
			reviews: 22,
			desc: "Smoky grilled specials, tacos, and bold house sauces.",
		},
		{
			name: "Mandala Crunch",
			img: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80",
			rating: "6,5",
			reviews: 38,
			desc: "Healthy bowls packed with greens, grains, and clean flavors.",
		},
		{
			name: "Veggie Tie",
			img: "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80",
			rating: "8,1",
			reviews: 12,
			desc: "Plant-forward comfort dishes with modern plating.",
		},
	];

	const recipes = [
		{
			id: 0,
			title: "Wallpapered Trout",
			restaurant: "El rinconcito",
			img: "https://images.unsplash.com/photo-1540420773420-3366772f4999?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80",
			price: "24€",
			rating: "9,2",
			desc: "Fresh trout marinated in citrus juices, served with wild asparagus and a hint of saffron.",
			ingredients: ["Fish", "Lemon", "Asparagus", "Saffron"],
		},
		{
			id: 1,
			title: "Cebiche de pata de mula",
			restaurant: "Burguer Town",
			img: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80",
			price: "35€",
			rating: "7,2",
			desc: "Roasted chicken taco, smoked and marinated in beer with a cow bean puree and tatemados chili sauce.",
			ingredients: ["Chicken", "Chili", "Corn", "Beer"],
		},
		{
			id: 2,
			title: "Mandala Crunch",
			restaurant: "Mandala Crunch",
			img: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80",
			price: "18€",
			rating: "6,5",
			desc: "A healthy bowl of fresh vegetables, quinoa, and avocado topped with sesame seeds.",
			ingredients: ["Avocado", "Quinoa", "Spinach", "Sesame"],
		},
		{
			id: 3,
			title: "Veggie Tie",
			restaurant: "Veggie Tie",
			img: "https://images.unsplash.com/photo-1626804475297-411d863452ef?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80",
			price: "22€",
			rating: "8,1",
			desc: "Grilled root vegetables served with a balsamic glaze and pine nuts.",
			ingredients: ["Carrots", "Beets", "Balsamic", "Nuts"],
		},
	];

	const ingredientImages = {
		Fish: "https://cdn-icons-png.flaticon.com/512/3058/3058995.png",
		Lemon: "https://cdn-icons-png.flaticon.com/512/517/517563.png",
		Asparagus: "https://cdn-icons-png.flaticon.com/512/1135/1135546.png",
		Saffron: "https://cdn-icons-png.flaticon.com/512/4861/4861536.png",
		Chicken: "https://cdn-icons-png.flaticon.com/512/1057/1057398.png",
		Chili: "https://cdn-icons-png.flaticon.com/512/2918/2918076.png",
		Corn: "https://cdn-icons-png.flaticon.com/512/1135/1135528.png",
		Beer: "https://cdn-icons-png.flaticon.com/512/931/931949.png",
		Avocado: "https://cdn-icons-png.flaticon.com/512/753/753820.png",
		Quinoa: "https://cdn-icons-png.flaticon.com/512/4669/4669466.png",
		Spinach: "https://cdn-icons-png.flaticon.com/512/1135/1135522.png",
		Sesame: "https://cdn-icons-png.flaticon.com/512/5029/5029236.png",
		Carrots: "https://cdn-icons-png.flaticon.com/512/234/234099.png",
		Beets: "https://cdn-icons-png.flaticon.com/512/1514/1514935.png",
		Balsamic: "https://cdn-icons-png.flaticon.com/512/119/119047.png",
		Nuts: "https://cdn-icons-png.flaticon.com/512/1652/1652078.png",
	};

	// --- state ---
	const [currentIndex, setCurrentIndex] = useState(1);
	const [currentView, setCurrentView] = useState("home");
	const [detailIndex, setDetailIndex] = useState(0);
	const [removedFloating, setRemovedFloating] = useState([]);
	const trackRef = useRef(null);
	const wrapperRef = useRef(null);
	const isDraggingRef = useRef(false);
	const startPosRef = useRef(0);
	const prevTranslateRef = useRef(0);
	const currentTranslateRef = useRef(0);
	const animationRef = useRef(null);
	const ITEM_WIDTH = 375;

	useEffect(() => {
		updateCarouselPosition(currentIndex);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, []);

	useEffect(() => {
		updateCarouselPosition(currentIndex);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [currentIndex]);

	function updateCarouselPosition(index) {
		const translateX = -index * ITEM_WIDTH;
		currentTranslateRef.current = translateX;
		prevTranslateRef.current = translateX;
		if (trackRef.current)
			trackRef.current.style.transform = `translateX(${translateX}px)`;
		updateItemTransforms(translateX);
	}

	function updateItemTransforms(translateX) {
		const items =
			trackRef.current?.querySelectorAll(".carousel-item") || [];
		const progress = (translateX - -currentIndex * ITEM_WIDTH) / ITEM_WIDTH;
		items.forEach((item, i) => {
			const distance = i - currentIndex + progress;
			const absDistance = Math.abs(distance);
			const scale = Math.max(0.6, 1 - absDistance * 0.35);
			const opacity = Math.max(0.4, 1 - absDistance * 0.5);
			item.style.transform = `scale(${scale})`;
			item.style.opacity = opacity;
			const plate = item.querySelector(".plate-img");
			if (plate) {
				plate.style.transform = `rotate(${distance * -18}deg)`;
			}
		});
	}

	// --- Drag handlers ---
	function getPositionX(ev) {
		return ev.type.includes("mouse")
			? ev.pageX
			: (ev.touches?.[0]?.clientX ?? 0);
	}

	function touchStart(ev) {
		isDraggingRef.current = true;
		startPosRef.current = getPositionX(ev);
		prevTranslateRef.current = currentTranslateRef.current;
		animationRef.current = requestAnimationFrame(animation);
		wrapperRef.current.style.cursor = "grabbing";
		wrapperRef.current.classList.add("dragging");
	}

	function touchMove(ev) {
		if (!isDraggingRef.current) return;
		if (ev.type === "touchmove") ev.preventDefault();
		const currentPosition = getPositionX(ev);
		currentTranslateRef.current =
			prevTranslateRef.current + currentPosition - startPosRef.current;
	}

	function touchEnd() {
		if (!isDraggingRef.current) return;
		isDraggingRef.current = false;
		cancelAnimationFrame(animationRef.current);
		wrapperRef.current.style.cursor = "grab";
		wrapperRef.current.classList.remove("dragging");

		const movedBy = currentTranslateRef.current - prevTranslateRef.current;
		const threshold = ITEM_WIDTH * 0.2;

		if (movedBy < -threshold && currentIndex < recipes.length - 1)
			setCurrentIndex((s) => s + 1);
		if (movedBy > threshold && currentIndex > 0)
			setCurrentIndex((s) => s - 1);

		updateCarouselPosition(currentIndex);
	}

	function animation() {
		if (isDraggingRef.current) {
			if (trackRef.current)
				trackRef.current.style.transform = `translateX(${currentTranslateRef.current}px)`;
			updateItemTransforms(currentTranslateRef.current);
			animationRef.current = requestAnimationFrame(animation);
		}
	}

	// --- Navigation ---
	function goToHome() {
		setCurrentView("home");
	}
	function goToList() {
		setCurrentView("list");
	}

	function openRestaurant(restaurantName) {
		const idx = recipes.findIndex((r) => r.restaurant === restaurantName);
		if (idx >= 0) {
			setCurrentIndex(idx);
			updateCarouselPosition(idx);
		}
		setCurrentView("home");
	}

	function openDetail(index) {
		setDetailIndex(index);
		setCurrentIndex(index);
		setCurrentView("detail");
		setRemovedFloating([]);
	}

	// --- Detail / Customize ---
	const [detailTab, setDetailTab] = useState("recipe");
	const [removedSet, setRemovedSet] = useState(new Set());

	function switchDetailTab(tabName) {
		setDetailTab(tabName);
	}

	function toggleIng(ing) {
		const next = new Set(removedSet);
		if (next.has(ing)) next.delete(ing);
		else next.add(ing);
		setRemovedSet(next);
	}

	function confirmCustomization() {
		const removedSources = Array.from(removedSet).map(
			(ing) => ingredientImages[ing] || "https://via.placeholder.com/45",
		);
		// show spinner briefly
		setTimeout(() => {
			setRemovedFloating(removedSources);
			setDetailTab("recipe");
			// clear selection
			setRemovedSet(new Set());
		}, 600);
	}

	return (
		<div className="boti-app">
			<div className="phone-frame">
				<div className="header">
					<i className="fas fa-bars menu-icon"></i>
					<div className="logo-area">
						<div className="logo-arc" />
						<div className="app-name">
							Bon appetit<span>!</span>
						</div>
					</div>
					<i className="fas fa-bell profile-icon"></i>
				</div>

				{/* Home View */}
				<div
					id="home-view"
					className={`view-container ${currentView === "home" ? "view-active" : "view-hidden"}`}
				>
					<div style={{ height: 40 }} />
					<div
						className="carousel-wrapper"
						id="carouselWrapper"
						ref={wrapperRef}
						onMouseDown={touchStart}
						onTouchStart={touchStart}
						onMouseMove={touchMove}
						onTouchMove={touchMove}
						onMouseUp={touchEnd}
						onMouseLeave={touchEnd}
						onTouchEnd={touchEnd}
					>
						<div
							className="carousel-track"
							id="track"
							ref={trackRef}
						>
							{recipes.map((recipe, index) => (
								<div
									key={recipe.id}
									className={`carousel-item ${index === currentIndex ? "active" : ""}`}
									onClick={() => {
										if (!isDraggingRef.current)
											openDetail(index);
									}}
								>
									<img
										src={recipe.img}
										className="plate-img"
										draggable={false}
										alt="plate"
									/>
									<div className="food-info">
										<h2 className="food-title">
											{recipe.title}
										</h2>
										<p className="food-sub">
											3 New recipes!
										</p>
									</div>
								</div>
							))}
						</div>
					</div>

					<div
						style={{
							textAlign: "center",
							color: "#555",
							fontSize: "0.7rem",
							position: "absolute",
							bottom: 100,
							width: "100%",
						}}
					>
						<i className="fas fa-chevron-up" />
						<br />
						Swipe for restaurants
					</div>
				</div>

				{/* Detail View */}
				<div
					id="detail-view"
					className={`view-container ${currentView === "detail" ? "view-active" : "view-hidden"}`}
				>
					<div
						className="detail-bg"
						style={{
							backgroundImage: `url("${recipes[detailIndex].img}")`,
						}}
					/>
					<div className="detail-overlay" />
					<div className="tabs">
						<div
							className={`tab ${detailTab === "recipe" ? "active" : ""}`}
							id="detail-tab-recipe"
							onClick={() => switchDetailTab("recipe")}
						>
							Recipes
						</div>
						<div
							className={`tab ${detailTab === "customize" ? "active" : ""}`}
							id="detail-tab-customize"
							onClick={() => switchDetailTab("customize")}
						>
							Customize
						</div>
					</div>

					<div
						className="back-btn"
						onClick={() => setCurrentView("home")}
					>
						<i className="fas fa-arrow-left" />
					</div>

					<div id="detail-content-area">
						<div className="detail-content">
							<div
								className={`recipe-content ${detailTab !== "recipe" ? "hidden" : ""}`}
								id="recipe-content"
								style={{ position: "relative" }}
							>
								<div id="removed-items-floating">
									{removedFloating.map((src, i) => (
										<div
											key={i}
											className="removed-float-item"
										>
											<img
												src={src}
												className="removed-float-img"
												alt="removed"
											/>
											<div className="removed-float-badge">
												<i className="fas fa-minus" />
											</div>
										</div>
									))}
								</div>

								<div className="tags">
									<div className="tag">
										<i className="fas fa-leaf" /> Saludable
									</div>
									<div className="tag">
										<i className="fas fa-percentage" /> Bajo
										en grasa
									</div>
									<div className="tag">
										<i className="fas fa-utensils" /> Receta
										disponible
									</div>
								</div>

								<h2 className="detail-title">
									{recipes[detailIndex].title}
								</h2>
								<p className="detail-desc">
									{recipes[detailIndex].desc}
								</p>

								<div id="info-panel" className="detail-footer">
									<div className="price">
										{recipes[detailIndex].price}
									</div>
									<div
										style={{
											display: "flex",
											flexDirection: "column",
											alignItems: "flex-end",
										}}
									>
										<div className="add-to-list">
											<i className="fas fa-plus" /> Add to
											list
										</div>
										<div
											style={{
												fontSize: "0.75rem",
												color: "#888",
												marginTop: 5,
											}}
										>
											★★★★★ (70) Reviews
										</div>
									</div>
								</div>

								<div style={{ marginTop: 10 }}>
									<p
										style={{
											fontSize: "0.7rem",
											color: "#888",
											marginBottom: 10,
											textTransform: "uppercase",
											letterSpacing: 1,
											fontWeight: 600,
										}}
									>
										Available at:
									</p>
									<div
										className="list-item"
										style={{
											padding: 12,
											background: "rgba(30, 30, 30, 0.8)",
											border: "1px solid rgba(255,255,255,0.1)",
											backdropFilter: "blur(10px)",
										}}
									>
										<img
											src={recipes[detailIndex].img}
											style={{
												width: 45,
												height: 45,
												borderRadius: 10,
												objectFit: "cover",
											}}
											alt="venue"
										/>
										<div className="list-details">
											<div
												className="list-name"
												style={{ fontSize: "0.95rem" }}
											>
												{
													recipes[detailIndex]
														.restaurant
												}
											</div>
											<div
												className="list-loc"
												style={{ margin: 0 }}
											>
												Madrid
											</div>
										</div>
										<div
											className="score-badge"
											style={{ fontSize: "1rem" }}
										>
											{recipes[detailIndex].rating}
										</div>
									</div>
								</div>
							</div>

							<div
								id="customize-panel"
								className={`customize-panel ${detailTab === "customize" ? "active" : ""}`}
							>
								<div
									style={{
										textAlign: "center",
										marginBottom: 30,
									}}
								>
									<h2
										className="detail-title"
										style={{ fontSize: "1.5rem" }}
									>
										{recipes[detailIndex].title}
									</h2>
									<p
										style={{
											color: "#888",
											fontSize: "0.8rem",
										}}
									>
										3 New recipes!
									</p>
								</div>

								<div className="ingredients-row">
									{recipes[detailIndex].ingredients.map(
										(ing) => (
											<div
												key={ing}
												className={`ingredient-item ${removedSet.has(ing) ? "removed" : ""}`}
												onClick={() => toggleIng(ing)}
											>
												<div className="remove-badge">
													<i className="fas fa-minus" />
												</div>
												<img
													src={
														ingredientImages[ing] ||
														"https://via.placeholder.com/45"
													}
													className="ing-img"
													alt={ing}
												/>
											</div>
										),
									)}
									<div
										className="confirm-btn"
										onClick={confirmCustomization}
									>
										<i className="fas fa-check" />
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>

				{/* List View */}
				<div
					id="list-view"
					className={`view-container ${currentView === "list" ? "view-active" : "view-hidden"}`}
				>
					<div
						className="tabs"
						style={{ position: "absolute", top: 0, width: "100%" }}
					>
						<div className="tab">Recipes</div>
						<div className="tab">Customize</div>
					</div>
					<div className="list-container" id="list-container">
						{restaurants.map((r) => (
							<div
								className="list-item"
								key={r.name}
								onClick={() => openRestaurant(r.name)}
							>
								<img
									src={r.img}
									alt="Restaurant"
									className="list-img"
								/>
								<div className="list-details">
									<div className="list-name">{r.name}</div>
									<div className="list-loc">Madrid</div>
									<div className="rating-row">
										<span className="stars">★★★★★</span>
										<span>({r.reviews}) Reviews</span>
									</div>
									<div className="list-desc">{r.desc}</div>
								</div>
								<div className="score-badge">{r.rating}</div>
							</div>
						))}
					</div>
				</div>

				<div className="bottom-nav">
					<div
						className={`nav-btn ${currentView === "list" ? "active" : ""}`}
						id="nav-list"
						onClick={goToList}
					>
						<i className="fas fa-store" />
					</div>
					<div className="add-btn">
						<i className="fas fa-plus" />
					</div>
					<div
						className={`nav-btn ${currentView === "home" ? "active" : ""}`}
						id="nav-home"
						onClick={goToHome}
					>
						<i className="fas fa-home" />
					</div>
				</div>
			</div>
		</div>
	);
}
