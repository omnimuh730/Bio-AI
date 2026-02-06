import React from "react";

const data = {
	calories: 150,
	protein: { value: 18, goal: 100 },
	carbs: { value: 60, goal: 250 },
	fat: { value: 20, goal: 70 },
};

export default function DailyFuel() {
	return (
		<div className="card daily-fuel">
			<div className="card-title">Daily Fuel</div>
			<div className="fuel-row">
				<div className="cal-circle">
					{data.calories}
					<br />
					<span>CALORIES</span>
				</div>
				<div className="bars">
					<div className="bar">
						<div className="label">
							Protein{" "}
							<span className="meta">
								{data.protein.value}g / {data.protein.goal}g
							</span>
						</div>
						<div className="meter">
							<div
								className="fill"
								style={{
									width: `${(data.protein.value / data.protein.goal) * 100}%`,
								}}
							/>
						</div>
					</div>
					<div className="bar">
						<div className="label">
							Carbs{" "}
							<span className="meta">
								{data.carbs.value}g / {data.carbs.goal}g
							</span>
						</div>
						<div className="meter">
							<div
								className="fill"
								style={{
									width: `${(data.carbs.value / data.carbs.goal) * 100}%`,
								}}
							/>
						</div>
					</div>
					<div className="bar">
						<div className="label">
							Fat{" "}
							<span className="meta">
								{data.fat.value}g / {data.fat.goal}g
							</span>
						</div>
						<div className="meter">
							<div
								className="fill"
								style={{
									width: `${(data.fat.value / data.fat.goal) * 100}%`,
								}}
							/>
						</div>
					</div>
				</div>
			</div>
		</div>
	);
}
