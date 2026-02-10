import React from "react";

const Sidebar = ({ activeTab, onTabChange, onExport }) => {
	return (
		<aside className="w-full md:w-64 bg-slate-900 text-slate-300 flex flex-col sticky top-0 h-auto md:h-screen z-20 shadow-2xl">
			<div className="p-6 flex items-center space-x-3 bg-slate-900/50">
				<div className="bg-gradient-to-tr from-indigo-500 to-purple-600 w-10 h-10 rounded-2xl flex items-center justify-center shadow-xl shadow-indigo-500/20">
					<i className="fas fa-layer-group text-white text-lg"></i>
				</div>
				<div>
					<h1 className="text-lg font-black text-white leading-none">
						FoodFlow
					</h1>
					<span className="text-[9px] text-slate-500 font-black uppercase tracking-[0.2em]">
						Data Studio
					</span>
				</div>
			</div>

			<nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
				{[
					{
						id: "inventory",
						label: "Inventory",
						icon: "fa-table-columns",
					},
					{
						id: "quality",
						label: "Quality Monitor",
						icon: "fa-microscope",
					},
					{
						id: "analytics",
						label: "Advanced Stats",
						icon: "fa-chart-line",
					},
				].map((tab) => (
					<button
						key={tab.id}
						onClick={() => onTabChange(tab.id)}
						className={`w-full flex items-center space-x-3 px-4 py-3 rounded-2xl transition-all border border-transparent ${
							activeTab === tab.id
								? "bg-indigo-600 text-white shadow-lg shadow-indigo-500/30"
								: "hover:bg-slate-800 hover:text-white"
						}`}
					>
						<i className={`fas ${tab.icon} w-5 text-center`}></i>
						<span className="font-bold text-sm tracking-tight">
							{tab.label}
						</span>
					</button>
				))}
			</nav>

			<div className="p-4 bg-slate-950/30">
				<button
					onClick={onExport}
					className="w-full py-3 px-4 bg-indigo-500/10 border border-indigo-500/20 text-indigo-400 rounded-2xl font-black text-xs uppercase tracking-widest hover:bg-indigo-500 hover:text-white transition-all shadow-sm"
				>
					<i className="fas fa-cloud-arrow-down mr-2"></i> Push to
					Production
				</button>
			</div>
		</aside>
	);
};

export default Sidebar;
