import React, { useState, useEffect, useRef } from "react";
import { FiChevronLeft, FiSend, FiMail, FiCpu } from "react-icons/fi";

// Initial Welcome Message
const INITIAL_MESSAGES = [
	{
		id: 1,
		text: "Hello! I'm BioAI Assistant. How can I help you with your settings today?",
		sender: "bot",
		time: "Now",
	},
];

export default function SettingsHelp({ onBack }) {
	const [messages, setMessages] = useState(INITIAL_MESSAGES);
	const [input, setInput] = useState("");
	const [isTyping, setIsTyping] = useState(false);
	const scrollRef = useRef(null);

	// Auto-scroll to bottom
	useEffect(() => {
		scrollRef.current?.scrollIntoView({ behavior: "smooth" });
	}, [messages, isTyping]);

	const handleSend = (e) => {
		e.preventDefault();
		if (!input.trim()) return;

		// 1. Add User Message
		const newUserMsg = {
			id: Date.now(),
			text: input,
			sender: "me",
			time: new Date().toLocaleTimeString([], {
				hour: "2-digit",
				minute: "2-digit",
			}),
		};

		setMessages((prev) => [...prev, newUserMsg]);
		setInput("");
		setIsTyping(true);

		// 2. Simulate Bot Delay & Response
		setTimeout(() => {
			setIsTyping(false);
			const newBotMsg = {
				id: Date.now() + 1,
				text: "I've received your query. Our AI is analyzing your data to provide the best health recommendation.", // Static response as requested
				sender: "bot",
				time: new Date().toLocaleTimeString([], {
					hour: "2-digit",
					minute: "2-digit",
				}),
			};
			setMessages((prev) => [...prev, newBotMsg]);
		}, 1500);
	};

	const handleContactSupport = () => {
		setIsTyping(true);
		setTimeout(() => {
			setIsTyping(false);
			setMessages((prev) => [
				...prev,
				{
					id: Date.now(),
					text: "Connecting you to a human agent... Please describe your issue in detail.",
					sender: "bot",
					time: "Just now",
				},
			]);
		}, 800);
	};

	return (
		<div className="sub-page-container help-page">
			{/* Inline Styles for Chat-Specific Animations */}
			<style>{`
        .help-page { background: #fdfbf9; height: 100%; display: flex; flex-direction: column; }
        
        .chat-area { 
          flex: 1; overflow-y: auto; padding: 20px; 
          display: flex; flex-direction: column; gap: 16px;
          padding-bottom: 100px; /* Space for input */
        }

        .msg-row { display: flex; gap: 12px; align-items: flex-end; opacity: 0; animation: popIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) forwards; }
        .msg-row.me { flex-direction: row-reverse; }
        
        @keyframes popIn {
          from { opacity: 0; transform: translateY(10px) scale(0.95); }
          to { opacity: 1; transform: translateY(0) scale(1); }
        }

        .msg-bubble {
          max-width: 75%; padding: 12px 16px; border-radius: 20px;
          font-size: 15px; line-height: 1.5; position: relative;
          box-shadow: 0 2px 5px rgba(0,0,0,0.03);
        }
        .msg-row.bot .msg-bubble {
          background: #fff; color: #1e293b;
          border-bottom-left-radius: 4px;
        }
        .msg-row.me .msg-bubble {
          background: linear-gradient(135deg, #FF6B45, #ff8f70);
          color: white;
          border-bottom-right-radius: 4px;
          box-shadow: 0 4px 12px rgba(255, 107, 69, 0.2);
        }

        .avatar-circle {
          width: 32px; height: 32px; border-radius: 50%;
          background: #e2e8f0; display: flex; align-items: center; justify-content: center;
          font-size: 14px; flex-shrink: 0;
        }

        .typing-indicator {
          display: flex; gap: 4px; padding: 12px 16px; background: #fff;
          border-radius: 20px; border-bottom-left-radius: 4px;
          width: fit-content; box-shadow: 0 2px 5px rgba(0,0,0,0.03);
        }
        .dot {
          width: 8px; height: 8px; background: #cbd5e1; border-radius: 50%;
          animation: bounce 1.4s infinite ease-in-out both;
        }
        .dot:nth-child(1) { animation-delay: -0.32s; }
        .dot:nth-child(2) { animation-delay: -0.16s; }
        
        @keyframes bounce {
          0%, 80%, 100% { transform: scale(0); }
          40% { transform: scale(1); }
        }

        .input-dock {
          position: absolute; bottom: 0; left: 0; right: 0;
          padding: 16px 20px 30px 20px;
          background: rgba(255,255,255,0.8);
          backdrop-filter: blur(20px);
          border-top: 1px solid rgba(0,0,0,0.05);
        }
        .input-bar {
          display: flex; gap: 10px; align-items: center;
          background: #f1f5f9; padding: 6px; border-radius: 30px;
          border: 1px solid rgba(0,0,0,0.02);
          transition: background 0.2s;
        }
        .input-bar:focus-within { background: #fff; border-color: #FF6B45; box-shadow: 0 0 0 3px rgba(255, 107, 69, 0.1); }
        
        .chat-input {
          flex: 1; border: none; background: transparent;
          padding: 10px 14px; font-size: 16px; outline: none; color: #334155;
        }
        
        .send-btn {
          width: 40px; height: 40px; border-radius: 50%;
          border: none; background: #FF6B45; color: white;
          display: flex; align-items: center; justify-content: center;
          cursor: pointer; transition: transform 0.1s;
        }
        .send-btn:active { transform: scale(0.9); }
        .send-btn:disabled { background: #cbd5e1; }
      `}</style>

			{/* Header with "Contact Us" Icon */}
			<header className="sub-header">
				<button className="back-btn" onClick={onBack}>
					<FiChevronLeft size={24} />
				</button>
				<div style={{ flex: 1, textAlign: "center" }}>
					<h2 className="sub-title">BioAI Support</h2>
					<span
						style={{
							fontSize: 11,
							color: "#10b981",
							fontWeight: 600,
							display: "block",
						}}
					>
						● Online
					</span>
				</div>
				<button
					className="back-btn"
					onClick={handleContactSupport}
					title="Contact Support Team"
					style={{ background: "#e0f2fe", color: "#0284c7" }}
				>
					<FiMail size={20} />
				</button>
			</header>

			{/* Chat Messages Area */}
			<div className="chat-area">
				{messages.map((msg) => (
					<div key={msg.id} className={`msg-row ${msg.sender}`}>
						{msg.sender === "bot" && (
							<div className="avatar-circle">
								<FiCpu />
							</div>
						)}
						<div className="msg-bubble">
							{msg.text}
							<div
								style={{
									fontSize: 10,
									marginTop: 4,
									color:
										msg.sender === "me"
											? "rgba(255,255,255,0.7)"
											: "#94a3b8",
									textAlign: "right",
								}}
							>
								{msg.time}
							</div>
						</div>
					</div>
				))}

				{isTyping && (
					<div className="msg-row bot">
						<div className="avatar-circle">
							<FiCpu />
						</div>
						<div className="typing-indicator">
							<div className="dot" />
							<div className="dot" />
							<div className="dot" />
						</div>
					</div>
				)}
				<div ref={scrollRef} />
			</div>

			{/* Glass Input Area */}
			<div className="input-dock">
				<form className="input-bar" onSubmit={handleSend}>
					<input
						className="chat-input"
						placeholder="Type a message..."
						value={input}
						onChange={(e) => setInput(e.target.value)}
					/>
					<button
						type="submit"
						className="send-btn"
						disabled={!input.trim()}
					>
						<FiSend size={18} style={{ marginLeft: -2 }} />
					</button>
				</form>
			</div>
		</div>
	);
}
