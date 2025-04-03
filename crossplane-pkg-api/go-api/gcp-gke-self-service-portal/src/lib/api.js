// src/lib/api.js
// API client for interacting with the Go backend

// Base URL for API calls
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080/api';

/**
 * Creates a new cluster
 * @param {Object} clusterData - Cluster creation data
 * @param {string} clusterData.clusterType - Type of cluster (eks or fargate)
 * @param {string} clusterData.clusterName - Name of the cluster
 * @param {number} [clusterData.nodeCount] - Number of nodes (for EKS clusters)
 * @param {string} clusterData.region - AWS region
 * @returns {Promise<{requestId: string, status: string}>}
 */
export async function createCluster(clusterData) {
	const response = await fetch(`${API_BASE_URL}/clusters`, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(clusterData)
	});

	if (!response.ok) {
		// Try to parse error message from response
		let errorMessage;
		try {
			const errorData = await response.json();
			errorMessage = errorData.error || `Error: ${response.status}`;
		} catch (e) {
			errorMessage = `Error: ${response.status}`;
		}
		throw new Error(errorMessage);
	}

	return await response.json();
}

/**
 * Gets the status of a cluster
 * @param {string} clusterName - Name of the cluster
 * @returns {Promise<Object>} Cluster details
 */
export async function getClusterStatus(clusterName) {
	const response = await fetch(`${API_BASE_URL}/clusters/${clusterName}`, {
		method: 'GET',
		headers: {
			'Content-Type': 'application/json'
		}
	});

	if (!response.ok) {
		if (response.status === 404) {
			throw new Error('Cluster not found');
		}

		// Try to parse error message from response
		let errorMessage;
		try {
			const errorData = await response.json();
			errorMessage = errorData.error || `Error: ${response.status}`;
		} catch (e) {
			errorMessage = `Error: ${response.status}`;
		}
		throw new Error(errorMessage);
	}

	return await response.json();
}

/**
 * Lists all clusters
 * @returns {Promise<Array>} List of clusters
 */
export async function listClusters() {
	const response = await fetch(`${API_BASE_URL}/clusters`, {
		method: 'GET',
		headers: {
			'Content-Type': 'application/json'
		}
	});

	if (!response.ok) {
		// Try to parse error message from response
		let errorMessage;
		try {
			const errorData = await response.json();
			errorMessage = errorData.error || `Error: ${response.status}`;
		} catch (e) {
			errorMessage = `Error: ${response.status}`;
		}
		throw new Error(errorMessage);
	}

	return await response.json();
}

/**
 * Deletes a cluster
 * @param {string} clusterName - Name of the cluster to delete
 * @returns {Promise<void>}
 */
export async function deleteCluster(clusterName) {
	const response = await fetch(`${API_BASE_URL}/clusters/${clusterName}`, {
		method: 'DELETE',
		headers: {
			'Content-Type': 'application/json'
		}
	});

	if (!response.ok) {
		if (response.status === 404) {
			throw new Error('Cluster not found');
		}

		// Try to parse error message from response
		let errorMessage;
		try {
			const errorData = await response.json();
			errorMessage = errorData.error || `Error: ${response.status}`;
		} catch (e) {
			errorMessage = `Error: ${response.status}`;
		}
		throw new Error(errorMessage);
	}
}
