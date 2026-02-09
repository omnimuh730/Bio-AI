import "../styles/recommended.css";
import { FiChevronRight } from "react-icons/fi";

export default function RecommendedCard({ onOpen }) {
	const item = {
		title: "Recommended: Salmon & Beet Salad",
		meta: "~ 420 kcal",
		img: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=100&q=80",
	};

	return (
		<div
			className="card recommended-card"
			onClick={(e) => {
				e.stopPropagation();
				if (onOpen) onOpen();
			}}
			role="button"
			tabIndex={0}
			style={{ cursor: "pointer" }}
		>
			<div className="rec-row">
				<img src={item.img} alt="food" />
				<div className="rec-info">
					<div className="title">{item.title}</div>
					<div className="sub">{item.meta}</div>
				</div>
				<div className="item-right">
					<FiChevronRight />
				</div>
			</div>
		</div>
	);
}
