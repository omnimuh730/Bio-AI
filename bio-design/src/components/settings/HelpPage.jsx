import React from "react";
import SettingsPageHeader from "./SettingsPageHeader";
import "./settings.css";

export default function HelpPage({ onBack }) {
	const [msgs, setMsgs] = React.useState([
		{ id: 1, text: "Hi — how can we help?", who: "agent" },
	]);
	const [draft, setDraft] = React.useState("");

	function send() {
		if (!draft.trim()) return;
		setMsgs((m) => [...m, { id: Date.now(), text: draft, who: "me" }]);
		setDraft("");
		setTimeout(() => {
			setMsgs((m) => [
				...m,
				{
					id: Date.now() + 1,
					text: "Thanks — we got your request and created ticket #1234",
					who: "agent",
				},
			]);
		}, 700);
	}

	return (
		<div className="settings-page enter">
			<SettingsPageHeader
				title="Help & Support"
				subtitle="Get help or open a support ticket"
				onBack={onBack}
			/>
			<div className="settings-page-content">
				<div className="chat">
					{msgs.map((m) => (
						<div
							key={m.id}
							className={`msg ${m.who === "me" ? "me" : ""}`}
						>
							{m.text}
						</div>
					))}
					<div style={{ display: "flex", gap: 8, marginTop: 12 }}>
						<input
							className="input"
							value={draft}
							onChange={(e) => setDraft(e.target.value)}
							placeholder="Describe your issue..."
						/>
						<button className="btn primary" onClick={send}>
							Send
						</button>
					</div>
				</div>

				<div className="settings-page-actions">
					<button className="btn primary" onClick={onBack}>
						Close
					</button>
				</div>
			</div>
		</div>
	);
}
