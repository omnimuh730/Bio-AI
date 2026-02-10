import React from "react";

const ManagementTabs = ({ managementSubTab, onChange }) => {
	return (
		<div className="flex flex-wrap gap-3">
			{[
				{ id: "merging", label: "Duplicates", icon: "fa-object-group" },
				{ id: "mapping", label: "Classification", icon: "fa-sitemap" },
				{ id: "audit", label: "Audit Logs", icon: "fa-history" },
			].map((sub) => (
				<button
					key={sub.id}
					onClick={() => onChange(sub.id)}
					className={`px-6 py-2 rounded-xl text-xs font-bold transition-all flex items-center space-x-2 ${
						managementSubTab === sub.id
							? "bg-slate-900 text-white shadow-lg"
							: "text-slate-400 hover:bg-slate-50"
					}`}
				>
					<i className={`fas ${sub.icon}`}></i>
					<span>{sub.label}</span>
				</button>
			))}
		</div>
	);
};

export default ManagementTabs;
