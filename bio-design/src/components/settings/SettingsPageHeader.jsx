import React from "react";
import { FiArrowLeft } from "react-icons/fi";

export default function SettingsPageHeader({ title, subtitle, onBack }) {
	return (
		<div className="settings-page-header">
			<button className="back-button" onClick={() => {
				// small exit animation before navigating back
				const root = document.querySelector('.settings-page.enter');
				if (root) {
					root.classList.remove('enter');
					root.classList.add('settings-page-exit');
					setTimeout(onBack, 260);
				} else {
					onBack();
				}
			}}>
				<FiArrowLeft size={24} />
			</button>
			</div>
		</div>
	);
}
