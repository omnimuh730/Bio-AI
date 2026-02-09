import React from "react";
import { FiBell } from "react-icons/fi";

export default function Header() {
	return (
		<div className="db-header">
			<div className="header-left">
				<p className="sub-greet">Good Morning,</p>
				<h1 className="user-name">Dekomori</h1>
			</div>
			<div className="header-right">
				<div className="icon-btn">
					<FiBell size={20} />
					<span className="dot-badge"></span>
				</div>
				<img
					src="https://ui-avatars.com/api/?name=Dekomori&background=6366f1&color=fff"
					alt="Profile"
					className="avatar"
				/>
			</div>

			<style>{`
        .db-header {
          display: flex; justify-content: space-between; align-items: center;
          padding: 20px 20px 10px 20px;
        }
        .sub-greet { font-size: 14px; color: #64748b; margin: 0; font-weight: 500; }
        .user-name { font-size: 26px; color: #0f172a; margin: 0; font-weight: 800; letter-spacing: -1px; }
        
        .header-right { display: flex; align-items: center; gap: 16px; }
        .icon-btn {
          position: relative; width: 40px; height: 40px; background: white;
          border-radius: 50%; display: flex; align-items: center; justify-content: center;
          color: #1e293b; box-shadow: 0 2px 8px rgba(0,0,0,0.05); cursor: pointer;
        }
        .dot-badge {
          position: absolute; top: 10px; right: 10px; width: 8px; height: 8px;
          background: #f43f5e; border-radius: 50%; border: 2px solid white;
        }
        .avatar {
          width: 44px; height: 44px; border-radius: 14px; border: 2px solid white;
          box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
        }
      `}</style>
		</div>
	);
}
