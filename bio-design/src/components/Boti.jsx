import React from "react";
import "../boti.css";

export default function Boti() {
	return (
		<div className="boti-root">
			<div className="header">
				<div className="left">
					<i className="fas fa-bars menu-icon" />
				</div>
				<div className="center">
					<div className="deliver">Deliver to</div>
					<div className="address">201 Pretty View Lane</div>
				</div>
				<div className="right">
					<i className="fas fa-bell profile-icon" />
				</div>
			</div>

			<div className="home-content">
				<div className="search">
					<input placeholder="Search for food or restaurant..." />
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

				<div className="section-head">Popular Food</div>
				<div className="popular-list">
					{[1, 2, 3].map((i) => (
						<div key={i} className="food-card">
							<div className="food-thumb" />
							<div className="food-info">
								<div className="name">Hyderabadi Biryani</div>
								<div className="meta">⭐ 4.9 • $7.50</div>
							</div>
						</div>
					))}
				</div>
			</div>

			<div className="bottom-nav">
				<div className="nav-item active">Home</div>
				<div className="nav-item">Favorites</div>
				<div className="nav-item">Cart</div>
				<div className="nav-item">Profile</div>
			</div>
		</div>
	);
}
