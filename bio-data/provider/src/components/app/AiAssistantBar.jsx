import React from "react";

const AiAssistantBar = ({
	aiQuery,
	onAiQueryChange,
	onSubmit,
	isAiLoading,
	aiResponse,
}) => {
	return (
		<>
			<form onSubmit={onSubmit} className="relative group">
				<input
					type="text"
					value={aiQuery}
					onChange={(e) => onAiQueryChange(e.target.value)}
					placeholder="Ask about data normalization, dietetic trends, or category re-mapping..."
					className="w-full pl-8 pr-44 py-6 bg-slate-50 border border-slate-200 rounded-[2rem] focus:outline-none focus:ring-8 focus:ring-indigo-500/5 transition-all text-lg font-bold placeholder:text-slate-300"
				/>
				<button
					type="submit"
					disabled={isAiLoading || !aiQuery.trim()}
					className="absolute right-4 top-4 bottom-4 bg-slate-900 text-white px-10 rounded-[1.5rem] font-black uppercase text-xs tracking-widest hover:bg-indigo-600 disabled:bg-slate-200 transition-all shadow-xl"
				>
					{isAiLoading ? (
						<i className="fas fa-spinner animate-spin"></i>
					) : (
						"Execute"
					)}
				</button>
			</form>

			{aiResponse && (
				<div className="mt-12 animate-in fade-in slide-in-from-top-4">
					<div className="bg-indigo-50/50 rounded-[2.5rem] p-12 border border-indigo-100/30">
						<div className="prose prose-indigo max-w-none text-slate-700 leading-relaxed text-lg font-medium">
							{aiResponse}
						</div>
					</div>
				</div>
			)}
		</>
	);
};

export default AiAssistantBar;
