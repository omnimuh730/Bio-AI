import React, { useState } from "react";
import axios from "axios";

const API_BASE = "http://localhost:5000/api";

export default function FatSecretApp() {
	const [activeTab, setActiveTab] = useState("Recipe");
	const [query, setQuery] = useState("");
	const [results, setResults] = useState(null);
	const [loading, setLoading] = useState(false);
	const [imageFile, setImageFile] = useState(null);
	const [imagePreview, setImagePreview] = useState("");

	// --- FILTERS ---
	const [showAdvanced, setShowAdvanced] = useState(false);
	const [region, setRegion] = useState("US"); // Shared by Recipe & Barcode
	const [recipeType, setRecipeType] = useState("All");
	const [withImages, setWithImages] = useState(true);

	// Nutrition Filters
	const [calories, setCalories] = useState({ min: "", max: "" });
	const [calActiveBtn, setCalActiveBtn] = useState(null);
	const [macros, setMacros] = useState({
		carb: { min: 0, max: 100 },
		prot: { min: 0, max: 100 },
		fat: { min: 0, max: 100 },
	});

	const tabs = [
		"Food",
		"Autocomplete",
		"Barcode",
		"Recipe",
		"Natural Language Processing",
		"Image Recognition",
	];

	const setCalorieRange = (label, min, max) => {
		if (calActiveBtn === label) {
			setCalories({ min: "", max: "" });
			setCalActiveBtn(null);
		} else {
			setCalories({ min, max });
			setCalActiveBtn(label);
		}
	};

	const handleMacroChange = (macro, type, value) => {
		setMacros((prev) => ({
			...prev,
			[macro]: { ...prev[macro], [type]: Number(value) },
		}));
	};

	const handleSearch = async (e) => {
		e.preventDefault();
		setLoading(true);
		setResults(null);

		try {
			let res;

			if (activeTab === "Image Recognition") {
				if (!imageFile) {
					setResults({ error: "Please select an image first." });
					setLoading(false);
					return;
				}
				const formData = new FormData();
				formData.append("image", imageFile);

				res = await axios.post(`${API_BASE}/recognize`, formData, {
					headers: { "Content-Type": "multipart/form-data" },
				});
			} else if (activeTab === "Food") {
				res = await axios.get(`${API_BASE}/search`, {
					params: { q: query },
				});
			} else if (activeTab === "Autocomplete") {
				res = await axios.get(`${API_BASE}/autocomplete`, {
					params: { q: query },
				});
			} else if (activeTab === "Barcode") {
				// Send code and region
				res = await axios.get(`${API_BASE}/barcode`, {
					params: { code: query, region: region },
				});
			} else if (activeTab === "Natural Language Processing") {
				res = await axios.get(`${API_BASE}/nlp`, {
					params: { q: query },
				});
			} else if (activeTab === "Recipe") {
				const params = {
					q: query,
					type: recipeType === "All" ? null : recipeType,
					images: withImages,
					region: region,
					cal_min: calories.min,
					cal_max: calories.max,
					carb_min: macros.carb.min,
					carb_max: macros.carb.max,
					prot_min: macros.prot.min,
					prot_max: macros.prot.max,
					fat_min: macros.fat.min,
					fat_max: macros.fat.max,
				};
				res = await axios.get(`${API_BASE}/recipes`, { params });
			}

			setResults(res.data);
		} catch (err) {
			console.error(err);
			setResults({
				error: "Search failed.",
				details: err.response?.data || err.message,
			});
		}
		setLoading(false);
	};

	const handleImageChange = (e) => {
		const file = e.target.files?.[0] || null;
		setImageFile(file);
		if (file) setImagePreview(URL.createObjectURL(file));
		else setImagePreview("");
	};

	const inputStyle = {
		width: "100%",
		padding: "12px",
		borderRadius: "6px",
		border: "1px solid #ddd",
		marginTop: "5px",
		boxSizing: "border-box",
	};

	return (
		<div
			style={{
				backgroundColor: "#fdfdfd",
				minHeight: "100vh",
				padding: "20px",
				fontFamily: '"Segoe UI", sans-serif',
			}}
		>
			<div style={{ maxWidth: "800px", margin: "40px auto" }}>
				{/* Navigation */}
				<nav
					style={{
						display: "flex",
						gap: "10px",
						marginBottom: "25px",
						overflowX: "auto",
						paddingBottom: "10px",
					}}
				>
					{tabs.map((tab) => (
						<button
							key={tab}
							onClick={() => {
								setActiveTab(tab);
								setResults(null);
								setQuery(""); // Clear query when switching tabs
								if (tab !== "Image Recognition") {
									setImageFile(null);
									setImagePreview("");
								}
							}}
							style={{
								border: "none",
								background: "transparent",
								cursor: "pointer",
								fontWeight: "600",
								whiteSpace: "nowrap",
								color: activeTab === tab ? "#28a745" : "#888",
								borderBottom:
									activeTab === tab
										? "2px solid #28a745"
										: "2px solid transparent",
								padding: "8px 5px",
							}}
						>
							{tab}
						</button>
					))}
				</nav>

				<div
					style={{
						background: "white",
						padding: "30px",
						borderRadius: "12px",
						boxShadow: "0 4px 15px rgba(0,0,0,0.05)",
					}}
				>
					<div
						style={{
							marginBottom: "20px",
							fontSize: "14px",
							color: "#666",
						}}
					>
						{activeTab === "Barcode" &&
							"Enter a UPC/EAN barcode. Note: Standard US UPCs (12 digits) will be automatically padded."}
					</div>

					{/* Region Selector (Visible for Recipe AND Barcode) */}
					{(activeTab === "Recipe" || activeTab === "Barcode") && (
						<div style={{ marginBottom: "20px" }}>
							<label
								style={{ fontWeight: "600", fontSize: "13px" }}
							>
								Region (Crucial for Barcodes)
							</label>
							<select
								value={region}
								onChange={(e) => setRegion(e.target.value)}
								style={inputStyle}
							>
								<option value="US">United States</option>
								<option value="AU">Australia</option>
								<option value="UK">United Kingdom</option>
								<option value="FR">France</option>
								<option value="DE">Germany</option>
								<option value="IT">Italy</option>
							</select>
						</div>
					)}

					{/* Recipe Type Selector */}
					{activeTab === "Recipe" && (
						<div style={{ marginBottom: "20px" }}>
							<label
								style={{ fontWeight: "600", fontSize: "13px" }}
							>
								Recipe Type
							</label>
							<select
								value={recipeType}
								onChange={(e) => setRecipeType(e.target.value)}
								style={inputStyle}
							>
								<option value="All">All</option>
								<option value="Breakfast">Breakfast</option>
								<option value="Lunch">Lunch</option>
								<option value="Dinner">Dinner</option>
								<option value="Snack">Snack</option>
							</select>
						</div>
					)}

					<form onSubmit={handleSearch}>
						{activeTab !== "Image Recognition" && (
							<>
								<label
									style={{
										fontWeight: "600",
										fontSize: "13px",
									}}
								>
									{activeTab === "Barcode"
										? "Barcode Number"
										: "Search Query"}
								</label>
								<input
									type="text"
									value={query}
									onChange={(e) => setQuery(e.target.value)}
									placeholder={
										activeTab === "Barcode"
											? "e.g. 070272002302"
											: "Enter search term..."
									}
									style={inputStyle}
								/>
							</>
						)}

						{/* Image Recognition UI */}
						{activeTab === "Image Recognition" && (
							<div style={{ marginTop: "5px" }}>
								<label
									style={{
										fontWeight: "600",
										fontSize: "13px",
									}}
								>
									Upload Food Image
								</label>
								<input
									type="file"
									accept="image/*"
									onChange={handleImageChange}
									style={inputStyle}
								/>
								{imagePreview && (
									<img
										src={imagePreview}
										alt="Preview"
										style={{
											marginTop: "15px",
											maxWidth: "100%",
											maxHeight: "300px",
											borderRadius: "8px",
											objectFit: "contain",
										}}
									/>
								)}
							</div>
						)}

						{/* Advanced Filters Toggle (Recipe Only) */}
						{activeTab === "Recipe" && (
							<div style={{ marginTop: "15px" }}>
								<button
									type="button"
									onClick={() =>
										setShowAdvanced(!showAdvanced)
									}
									style={{
										background: "white",
										border: "1px solid #28a745",
										color: "#28a745",
										padding: "8px 12px",
										borderRadius: "4px",
										cursor: "pointer",
										fontSize: "13px",
									}}
								>
									{showAdvanced
										? "Hide Advanced Filters"
										: "Show Advanced Search Filters"}
								</button>
							</div>
						)}

						{/* Advanced Filters (Recipe Only) */}
						{activeTab === "Recipe" && showAdvanced && (
							<div
								style={{
									marginTop: "20px",
									padding: "20px",
									border: "1px solid #eee",
									borderRadius: "8px",
									background: "#fafafa",
								}}
							>
								{/* Calories */}
								<div style={{ marginBottom: "20px" }}>
									<label
										style={{
											fontWeight: "600",
											fontSize: "14px",
											marginBottom: "10px",
											display: "block",
										}}
									>
										Calories
									</label>
									<div
										style={{
											display: "flex",
											gap: "10px",
											flexWrap: "wrap",
										}}
									>
										<button
											type="button"
											style={{
												padding: "6px 12px",
												borderRadius: "15px",
												border:
													calActiveBtn === "u100"
														? "none"
														: "1px solid #ccc",
												background:
													calActiveBtn === "u100"
														? "#28a745"
														: "white",
												color:
													calActiveBtn === "u100"
														? "white"
														: "#666",
												cursor: "pointer",
											}}
											onClick={() =>
												setCalorieRange("u100", 0, 100)
											}
										>
											Under 100
										</button>
										<button
											type="button"
											style={{
												padding: "6px 12px",
												borderRadius: "15px",
												border:
													calActiveBtn === "100-250"
														? "none"
														: "1px solid #ccc",
												background:
													calActiveBtn === "100-250"
														? "#28a745"
														: "white",
												color:
													calActiveBtn === "100-250"
														? "white"
														: "#666",
												cursor: "pointer",
											}}
											onClick={() =>
												setCalorieRange(
													"100-250",
													100,
													250,
												)
											}
										>
											100 - 250
										</button>
										<button
											type="button"
											style={{
												padding: "6px 12px",
												borderRadius: "15px",
												border:
													calActiveBtn === "250-500"
														? "none"
														: "1px solid #ccc",
												background:
													calActiveBtn === "250-500"
														? "#28a745"
														: "white",
												color:
													calActiveBtn === "250-500"
														? "white"
														: "#666",
												cursor: "pointer",
											}}
											onClick={() =>
												setCalorieRange(
													"250-500",
													250,
													500,
												)
											}
										>
											250 - 500
										</button>
									</div>
								</div>
							</div>
						)}

						<button
							type="submit"
							disabled={loading}
							style={{
								width: "100%",
								padding: "14px",
								background: loading ? "#96d3a4" : "#28a745",
								color: "white",
								border: "none",
								borderRadius: "6px",
								fontWeight: "bold",
								fontSize: "16px",
								marginTop: "20px",
								cursor: loading ? "not-allowed" : "pointer",
							}}
						>
							{loading ? "Processing..." : "Run Search"}
						</button>
					</form>

					{/* Results Display */}
					<div style={{ marginTop: "30px" }}>
						{results && (
							<div
								style={{
									background: "#f4f4f4",
									padding: "15px",
									borderRadius: "8px",
									overflowX: "auto",
									border: "1px solid #ddd",
								}}
							>
								<pre
									style={{ fontSize: "12px", color: "#333" }}
								>
									{JSON.stringify(results, null, 2)}
								</pre>
							</div>
						)}
					</div>
				</div>
			</div>
		</div>
	);
}
