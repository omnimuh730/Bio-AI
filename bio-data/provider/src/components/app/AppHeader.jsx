import React from "react";

const AppHeader = ({
	activeTab,
	importBarcode,
	onImportBarcodeChange,
	onImport,
	isImporting,
}) => {
	return (
		<header className="bg-white border-b border-slate-100 px-8 py-4 flex-shrink-0 z-10 flex justify-between items-center shadow-sm">
			<div className="flex items-center space-x-4">
				<h2 className="text-xl font-black text-slate-800 uppercase tracking-tighter">
					{activeTab}
				</h2>
				<div className="h-6 w-px bg-slate-200"></div>
				<div className="flex items-center space-x-2 bg-emerald-50 px-3 py-1 rounded-full">
					<span className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-ping"></span>
					<span className="text-[10px] font-black text-emerald-600 uppercase">
						Live Sync Active
					</span>
				</div>
			</div>

			<div className="flex items-center space-x-6">
				<div className="hidden xl:flex items-center space-x-2 text-xs font-bold text-slate-400">
					<i className="fas fa-clock"></i>
					<span>Last Import: 14m ago</span>
				</div>
				<div className="flex items-center space-x-2">
					<input
						type="text"
						placeholder="Import barcode (e.g. 3017620422003)"
						className="p-2 pl-3 pr-12 rounded-xl border border-slate-200 text-xs bg-white"
						value={importBarcode}
						onChange={(e) => onImportBarcodeChange(e.target.value)}
						aria-label="Import barcode"
					/>
					<button
						onClick={onImport}
						className="h-10 px-4 rounded-xl bg-indigo-600 text-white font-bold text-xs hover:bg-indigo-700 transition-colors"
					>
						{isImporting ? "Importing..." : "Import"}
					</button>
				</div>{" "}
				<button className="h-10 w-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-400 hover:bg-slate-100 hover:text-indigo-600 transition-all border border-slate-100">
					<i className="fas fa-gear"></i>
				</button>
				<div className="flex items-center space-x-3 pl-4 border-l border-slate-100">
					<div className="text-right">
						<p className="text-xs font-black text-slate-800">
							Admin User
						</p>
						<p className="text-[10px] text-slate-400 font-bold">
							Data Steward
						</p>
					</div>
					<div className="h-10 w-10 bg-indigo-600 rounded-2xl flex items-center justify-center text-white font-black border-2 border-indigo-200 shadow-lg shadow-indigo-100">
						AU
					</div>
				</div>
			</div>
		</header>
	);
};

export default AppHeader;
