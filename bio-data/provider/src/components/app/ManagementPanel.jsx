import React from "react";
import AuditLogViewer from "../AuditLogViewer";
import CategoryMapping from "../CategoryMapping";
import DataManagement from "../DataManagement";

const ManagementPanel = ({ managementSubTab, products, auditLogs, onMap }) => {
	if (managementSubTab === "merging") {
		return <DataManagement products={products} />;
	}

	if (managementSubTab === "mapping") {
		return <CategoryMapping products={products} onMap={onMap} />;
	}

	if (managementSubTab === "audit") {
		return <AuditLogViewer logs={auditLogs} products={products} />;
	}

	return null;
};

export default ManagementPanel;
