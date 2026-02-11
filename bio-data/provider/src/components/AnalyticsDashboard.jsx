import React, { useMemo } from "react";
import {
	BarChart,
	Bar,
	XAxis,
	YAxis,
	CartesianGrid,
	Tooltip,
	ResponsiveContainer,
	Cell,
	LineChart,
	Line,
	PieChart,
	Pie,
	Legend,
} from "recharts";
import {
	Box,
	Grid,
	Card,
	CardContent,
	Typography,
	Button,
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableRow,
} from "@mui/material";

function getWeekKey(ts) {
	const d = new Date(ts);
	const onejan = new Date(d.getFullYear(), 0, 1);
	const days = Math.floor((d - onejan) / (24 * 60 * 60 * 1000));
	const week = Math.ceil((days + onejan.getDay() + 1) / 7);
	return `${d.getFullYear()}-W${String(week).padStart(2, "0")}`;
}

const APP_NOW = Date.now();

function easeVal(v) {
	if (v === undefined || v === null || isNaN(v)) return 0;
	return Number(v);
}

const AnalyticsDashboard = ({ products = [] }) => {
	const totalProducts = products.length;
	const avgQuality = (
		products.reduce((s, p) => s + (easeVal(p.quality_score) || 0), 0) /
		Math.max(1, totalProducts)
	).toFixed(1);

	const completeness = useMemo(() => {
		const fields = [
			"image_url",
			"nutriscore_grade",
			"nutriments",
			"ingredients_text",
		];
		let totalChecks = 0;
		let present = 0;
		for (const p of products) {
			for (const f of fields) {
				totalChecks++;
				if (p[f] !== undefined && p[f] !== null && p[f] !== "")
					present++;
			}
		}
		return totalChecks === 0
			? 100
			: Math.round((present / totalChecks) * 100);
	}, [products]);

	const flaggedCount = products.filter(
		(p) =>
			p.status === "flagged" || (p.quality_score && p.quality_score < 60),
	).length;
	const flaggedPct = Math.round(
		(flaggedCount / Math.max(1, totalProducts)) * 100,
	);

	const qualitySeries = useMemo(() => {
		const map = new Map();
		for (const p of products) {
			const ts =
				p.last_modified || p.created_at || p.updated_at || APP_NOW;
			const key = getWeekKey(ts);
			if (!map.has(key)) map.set(key, { sum: 0, count: 0 });
			map.get(key).sum += easeVal(p.quality_score) || 0;
			map.get(key).count += 1;
		}
		const entries = Array.from(map.entries()).sort((a, b) =>
			a[0] > b[0] ? 1 : -1,
		);
		const series = entries.map(([key, v]) => ({
			week: key,
			avg: v.count ? +(v.sum / v.count).toFixed(1) : 0,
		}));
		return series.slice(-12);
	}, [products]);

	const tagsBreakdown = useMemo(() => {
		const counts = {};
		for (const p of products) {
			if (!Array.isArray(p.tags)) continue;
			for (const t of p.tags) counts[t] = (counts[t] || 0) + 1;
		}
		return Object.entries(counts)
			.sort((a, b) => b[1] - a[1])
			.map(([name, value]) => ({ name, value }));
	}, [products]);

	const topBrands = useMemo(() => {
		const m = {};
		for (const p of products) {
			const b = p.brands || "(unknown)";
			if (!m[b]) m[b] = { count: 0, sumQuality: 0 };
			m[b].count++;
			m[b].sumQuality += easeVal(p.quality_score) || 0;
		}
		return Object.entries(m)
			.map(([brand, v]) => ({
				brand,
				count: v.count,
				avgQuality: +(v.sumQuality / v.count).toFixed(1),
			}))
			.sort((a, b) => b.count - a.count)
			.slice(0, 10);
	}, [products]);

	const downloadCsv = () => {
		const rows = [
			"brand,count,avgQuality",
			...topBrands.map(
				(r) =>
					`${r.brand.replace(/,/g, ";")},${r.count},${r.avgQuality}`,
			),
		];
		const blob = new Blob([rows.join("\n")], { type: "text/csv" });
		const url = URL.createObjectURL(blob);
		const a = document.createElement("a");
		a.href = url;
		a.download = `analytics_top_brands_${new Date().toISOString().split("T")[0]}.csv`;
		a.click();
	};

	return (
		<Box className="space-y-6">
			<Grid container spacing={2}>
				<Grid item xs={12} md={3}>
					<Card>
						<CardContent>
							<Typography variant="caption" color="textSecondary">
								Total Products
							</Typography>
							<Typography variant="h5">
								{totalProducts}
							</Typography>
						</CardContent>
					</Card>
				</Grid>
				<Grid item xs={12} md={3}>
					<Card>
						<CardContent>
							<Typography variant="caption" color="textSecondary">
								Avg Quality Score
							</Typography>
							<Typography variant="h5">{avgQuality}%</Typography>
						</CardContent>
					</Card>
				</Grid>
				<Grid item xs={12} md={3}>
					<Card>
						<CardContent>
							<Typography variant="caption" color="textSecondary">
								Completeness
							</Typography>
							<Typography variant="h5">
								{completeness}%
							</Typography>
						</CardContent>
					</Card>
				</Grid>
				<Grid item xs={12} md={3}>
					<Card>
						<CardContent>
							<Typography variant="caption" color="textSecondary">
								Flagged
							</Typography>
							<Typography variant="h5">{flaggedPct}%</Typography>
						</CardContent>
					</Card>
				</Grid>
			</Grid>

			<Grid container spacing={2} className="mt-4">
				<Grid item xs={12} lg={6}>
					<Card>
						<CardContent>
							<div className="flex items-center justify-between mb-4">
								<Typography variant="h6">
									Average Quality Over Time
								</Typography>
								<Button
									size="small"
									onClick={() =>
										navigator.clipboard.writeText(
											JSON.stringify(qualitySeries),
										)
									}
								>
									Copy Series
								</Button>
							</div>
							<div style={{ height: 240 }}>
								<ResponsiveContainer width="100%" height="100%">
									<LineChart data={qualitySeries}>
										<CartesianGrid
											strokeDasharray="3 3"
											vertical={false}
											stroke="#f1f5f9"
										/>
										<XAxis
											dataKey="week"
											axisLine={false}
											tickLine={false}
										/>
										<YAxis domain={[0, 100]} />
										<Tooltip />
										<Line
											type="monotone"
											dataKey="avg"
											stroke="#2563eb"
											strokeWidth={2}
											dot={{ r: 3 }}
										/>
									</LineChart>
								</ResponsiveContainer>
							</div>
						</CardContent>
					</Card>
				</Grid>

				<Grid item xs={12} lg={6}>
					<Card>
						<CardContent>
							<div className="flex items-center justify-between mb-4">
								<Typography variant="h6">
									Issue Breakdown
								</Typography>
								<Button size="small" onClick={downloadCsv}>
									Export
								</Button>
							</div>
							<div style={{ height: 240 }}>
								<ResponsiveContainer width="100%" height="100%">
									<PieChart>
										<Pie
											data={tagsBreakdown.slice(0, 6)}
											dataKey="value"
											nameKey="name"
											innerRadius={40}
											outerRadius={80}
											label
										/>
										<Tooltip />
										<Legend />
									</PieChart>
								</ResponsiveContainer>
							</div>
							<div className="mt-3">
								{tagsBreakdown.slice(0, 6).map((t) => (
									<div
										key={t.name}
										className="text-sm text-slate-600"
									>
										{t.name}: <strong>{t.value}</strong>
									</div>
								))}
							</div>
						</CardContent>
					</Card>
				</Grid>
			</Grid>

			<Card className="mt-4">
				<CardContent>
					<div className="flex items-center justify-between mb-4">
						<Typography variant="h6">Top Brands</Typography>
						<Button size="small" onClick={downloadCsv}>
							Download CSV
						</Button>
					</div>
					<Table size="small">
						<TableHead>
							<TableRow>
								<TableCell>Brand</TableCell>
								<TableCell align="right">Count</TableCell>
								<TableCell align="right">Avg Quality</TableCell>
							</TableRow>
						</TableHead>
						<TableBody>
							{topBrands.map((b) => (
								<TableRow key={b.brand}>
									<TableCell>{b.brand}</TableCell>
									<TableCell align="right">
										{b.count}
									</TableCell>
									<TableCell align="right">
										{b.avgQuality}
									</TableCell>
								</TableRow>
							))}
						</TableBody>
					</Table>
				</CardContent>
			</Card>
		</Box>
	);
};

export default AnalyticsDashboard;
