import React from "react";
import "../home.css";

export default function Home() {
	return (
		<div className="home-root">
			<div className="header">
				<div className="avatar">A</div>
				<div className="center">
					<div className="deliver">Deliver to</div>
					<div className="address">201 Pretty View Lane</div>
				</div>
				<div className="bell">!</div>
			</div>

			<div className="home-content">
				<div className="search-row">
					<div className="search">
						<input placeholder="Search for food or restaurant..." />
					</div>
					<button className="filter-btn" aria-label="Filter">
						<span className="filter-dot" />
						<span className="filter-dot" />
						<span className="filter-dot" />
					</button>
				</div>

				<div className="row-head">
					<span>Special offers</span>
					<span className="link">See all</span>
				</div>
				<div className="special">
					<div className="special-left">
						<div className="percent">30%</div>
						<div>
							<div className="special-title">Off on Shrimp Noodles</div>
							<div className="special-sub">Tasty &amp; spicy</div>
						</div>
					</div>
					<div className="special-thumb" />
				</div>

				<div className="category-row">
					{["Biryani", "Noodles", "Desserts"].map((c, i) => (
						<div key={c} className={`chip ${i === 0 ? "active" : ""}`}>
							{c}
						</div>
					))}
				</div>

				<div className="row-head">
					<span>Popular Food</span>
					<span className="link">View all</span>
				</div>
				<div className="popular-grid">
					{[
						{
							name: "Hyderabadi Biryani",
							price: "$7.50",
							rating: "4.9",
							img: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80",
						},
						{
							name: "Veg Biryani",
							price: "$5.50",
							rating: "4.7",
							img: "https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=400&q=80",
						},
					].map((item) => (
						<div key={item.name} className="food-card">
							<div className="food-thumb" style={{ backgroundImage: `url(${item.img})` }} />
							<div className="food-info">
								<div className="name">{item.name}</div>
								<div className="meta">
									<span className="star">*</span> {item.rating}
									<span className="dot">•</span> {item.price}
								</div>
							</div>
							<div className="heart">+</div>
						</div>
					))}
				</div>
			</div>

			<div className="bottom-nav">
				<div className="nav-item active">
					<span className="nav-icon" />
					Home
				</div>
				<div className="nav-item">
					<span className="nav-icon" />
					Fav
				</div>
				<div className="nav-item">
					<span className="nav-icon" />
					Cart
				</div>
				<div className="nav-item">
					<span className="nav-icon" />
					Me
				</div>
			</div>
		</div>
	);
}
