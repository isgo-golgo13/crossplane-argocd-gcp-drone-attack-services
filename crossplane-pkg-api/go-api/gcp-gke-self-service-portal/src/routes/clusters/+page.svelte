<script>
	import { page } from '$app/stores';
	import { onMount } from 'svelte';

	// Get cluster name from query params
	let clusterName = $page.url.searchParams.get('cluster_name') || '';
	let requestId = $page.url.searchParams.get('request_id') || '';

	let cluster = null;
	let loading = true;
	let error = null;
	let polling = null;

	onMount(async () => {
		fetchClusterStatus();

		// Poll for updates if we're viewing a cluster that might be provisioning
		polling = setInterval(fetchClusterStatus, 10000);

		return () => {
			if (polling) clearInterval(polling);
		};
	});

	async function fetchClusterStatus() {
		try {
			// In a real implementation, this would be an API call
			// const response = await fetch(`/api/clusters/${clusterName}`);
			// cluster = await response.json();

			// Mock data for demonstration
			await new Promise((resolve) => setTimeout(resolve, 1000));

			cluster = {
				name: clusterName || 'demo-cluster',
				clusterType: Math.random() > 0.5 ? 'eks' : 'fargate',
				status: generateStatus(),
				region: 'us-west-2',
				nodeCount: 3,
				requestId: requestId || '12345-mock-id',
				createdAt: new Date().toISOString(),
				kubeconfig: cluster?.status === 'READY' ? generateMockKubeconfig() : null
			};

			loading = false;

			// If the cluster is in a terminal state, stop polling
			if (cluster.status === 'READY' || cluster.status === 'FAILED') {
				if (polling) {
					clearInterval(polling);
					polling = null;
				}
			}
		} catch (err) {
			error = `Failed to get cluster status: ${err.message}`;
			loading = false;

			if (polling) {
				clearInterval(polling);
				polling = null;
			}
		}
	}

	function generateStatus() {
		// For demo purposes, randomly progress through states
		if (!cluster) return 'PENDING';

		const statuses = ['PENDING', 'PROVISIONING', 'READY', 'FAILED'];
		const currentIndex = statuses.indexOf(cluster.status);

		if (currentIndex === -1 || currentIndex === statuses.length - 1) {
			return statuses[Math.floor(Math.random() * 3)]; // Random state, but not always FAILED
		}

		// 80% chance to progress to next state
		return Math.random() < 0.8 ? statuses[currentIndex + 1] : cluster.status;
	}

	function generateMockKubeconfig() {
		return `apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0t...
    server: https://mock-eks-endpoint.us-west-2.eks.amazonaws.com
  name: ${clusterName || 'demo-cluster'}.us-west-2.eksctl.io
contexts:
- context:
    cluster: ${clusterName || 'demo-cluster'}.us-west-2.eksctl.io
    user: admin@${clusterName || 'demo-cluster'}.us-west-2.eksctl.io
  name: admin@${clusterName || 'demo-cluster'}.us-west-2.eksctl.io
current-context: admin@${clusterName || 'demo-cluster'}.us-west-2.eksctl.io
kind: Config
preferences: {}
users:
- name: admin@${clusterName || 'demo-cluster'}.us-west-2.eksctl.io
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - eks
      - get-token
      - --cluster-name
      - ${clusterName || 'demo-cluster'}
      - --region
      - us-west-2
      command: aws`;
	}

	function getStatusClass(status) {
		switch (status) {
			case 'READY':
				return 'bg-green-100 text-green-800';
			case 'PROVISIONING':
				return 'bg-blue-100 text-blue-800';
			case 'PENDING':
				return 'bg-yellow-100 text-yellow-800';
			case 'FAILED':
				return 'bg-red-100 text-red-800';
			default:
				return 'bg-gray-100 text-gray-800';
		}
	}

	function formatDate(dateString) {
		if (!dateString) return 'N/A';
		return new Date(dateString).toLocaleString();
	}

	function downloadKubeconfig() {
		if (!cluster?.kubeconfig) return;

		const element = document.createElement('a');
		const file = new Blob([cluster.kubeconfig], { type: 'text/plain' });
		element.href = URL.createObjectURL(file);
		element.download = `kubeconfig-${cluster.name}.yaml`;
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);
	}
</script>

// src/routes/clusters/status/+page.svelte
<div class="space-y-6">
	<button
		class="flex items-center text-gray-600 hover:text-gray-900"
		on:click={() => history.back()}
	>
		<svg
			xmlns="http://www.w3.org/2000/svg"
			class="mr-1 h-5 w-5"
			viewBox="0 0 20 20"
			fill="currentColor"
		>
			<path
				fill-rule="evenodd"
				d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z"
				clip-rule="evenodd"
			/>
		</svg>
		Back to Clusters
	</button>

	<div class="overflow-hidden rounded-lg border bg-white shadow-sm">
		<div class="flex items-center justify-between border-b p-4">
			<h1 class="text-xl font-bold">
				{#if loading}
					Loading Cluster...
				{:else if error}
					Cluster Details
				{:else}
					{cluster.name}
				{/if}
			</h1>

			{#if cluster?.status === 'READY'}
				<button
					class="bg-primary-600 hover:bg-primary-700 flex items-center rounded-md px-3 py-1.5 text-sm font-medium text-white"
					on:click={downloadKubeconfig}
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						class="mr-1 h-4 w-4"
						fill="none"
						viewBox="0 0 24 24"
						stroke="currentColor"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
						/>
					</svg>
					Download Kubeconfig
				</button>
			{/if}
		</div>

		{#if loading}
			<div class="flex justify-center p-12">
				<div
					class="border-primary-600 h-12 w-12 animate-spin rounded-full border-t-2 border-b-2"
				></div>
			</div>
		{:else if error}
			<div class="p-6">
				<div class="rounded border border-red-400 bg-red-100 px-4 py-3 text-red-700">
					<p>{error}</p>
				</div>
			</div>
		{:else}
			<div class="grid grid-cols-1 gap-6 p-6 md:grid-cols-2">
				<div class="space-y-4">
					<div>
						<h3 class="text-sm font-medium text-gray-500">Cluster Name</h3>
						<p class="mt-1 text-lg">{cluster.name}</p>
					</div>

					<div>
						<h3 class="text-sm font-medium text-gray-500">Type</h3>
						<p class="mt-1 text-lg">
							{cluster.clusterType === 'eks' ? 'EKS Managed Node Groups' : 'EKS Fargate'}
						</p>
					</div>

					<div>
						<h3 class="text-sm font-medium text-gray-500">Status</h3>
						<p class="mt-1">
							<span
								class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium {getStatusClass(
									cluster.status
								)}"
							>
								{#if cluster.status === 'PROVISIONING'}
									<svg
										class="mr-2 -ml-1 h-3 w-3 animate-spin"
										xmlns="http://www.w3.org/2000/svg"
										fill="none"
										viewBox="0 0 24 24"
									>
										<circle
											class="opacity-25"
											cx="12"
											cy="12"
											r="10"
											stroke="currentColor"
											stroke-width="4"
										></circle>
										<path
											class="opacity-75"
											fill="currentColor"
											d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
										></path>
									</svg>
								{/if}
								{cluster.status}
							</span>
						</p>
					</div>

					<div>
						<h3 class="text-sm font-medium text-gray-500">Request ID</h3>
						<p class="mt-1 font-mono text-lg text-sm">{cluster.requestId}</p>
					</div>
				</div>

				<div class="space-y-4">
					<div>
						<h3 class="text-sm font-medium text-gray-500">Region</h3>
						<p class="mt-1 text-lg">{cluster.region}</p>
					</div>

					{#if cluster.clusterType === 'eks' && cluster.nodeCount}
						<div>
							<h3 class="text-sm font-medium text-gray-500">Node Count</h3>
							<p class="mt-1 text-lg">{cluster.nodeCount}</p>
						</div>
					{/if}

					<div>
						<h3 class="text-sm font-medium text-gray-500">Created At</h3>
						<p class="mt-1 text-lg">{formatDate(cluster.createdAt)}</p>
					</div>
				</div>
			</div>

			{#if cluster.status === 'PROVISIONING' || cluster.status === 'PENDING'}
				<div class="p-6 pt-0">
					<div class="border-l-4 border-blue-400 bg-blue-50 p-4">
						<div class="flex">
							<div class="flex-shrink-0">
								<svg
									class="h-5 w-5 text-blue-400"
									xmlns="http://www.w3.org/2000/svg"
									viewBox="0 0 20 20"
									fill="currentColor"
								>
									<path
										fill-rule="evenodd"
										d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
										clip-rule="evenodd"
									/>
								</svg>
							</div>
							<div class="ml-3">
								<p class="text-sm text-blue-700">
									Your cluster is being provisioned. This process typically takes 10-15 minutes.
								</p>
							</div>
						</div>
					</div>
				</div>
			{:else if cluster.status === 'FAILED'}
				<div class="p-6 pt-0">
					<div class="border-l-4 border-red-400 bg-red-50 p-4">
						<div class="flex">
							<div class="flex-shrink-0">
								<svg
									class="h-5 w-5 text-red-400"
									xmlns="http://www.w3.org/2000/svg"
									viewBox="0 0 20 20"
									fill="currentColor"
								>
									<path
										fill-rule="evenodd"
										d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
										clip-rule="evenodd"
									/>
								</svg>
							</div>
							<div class="ml-3">
								<p class="text-sm text-red-700">
									Cluster provisioning failed. Please check the logs or contact support for
									assistance.
								</p>
							</div>
						</div>
					</div>
				</div>
			{/if}

			{#if cluster.status === 'READY' && cluster.kubeconfig}
				<div class="p-6 pt-0">
					<h3 class="mb-2 text-sm font-medium text-gray-500">Kubeconfig Preview</h3>
					<div class="max-h-60 overflow-auto rounded-md border bg-gray-50 p-3">
						<pre class="font-mono text-xs">{cluster.kubeconfig}</pre>
					</div>
				</div>
			{/if}
		{/if}
	</div>
</div>
