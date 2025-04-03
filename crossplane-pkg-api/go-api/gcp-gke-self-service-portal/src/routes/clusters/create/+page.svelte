<script>
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	// Form state
	let clusterType = 'eks';
	let clusterName = '';
	let nodeCount = 2;
	let region = 'us-west-2';
	let isSubmitting = false;
	let errors = {};

	// Get cluster type from query parameter if available
	onMount(() => {
		const type = $page.url.searchParams.get('type');
		if (type === 'eks' || type === 'fargate') {
			clusterType = type;
		}
	});

	// Available AWS regions
	const regions = [
		{ value: 'us-east-1', label: 'US East (N. Virginia)' },
		{ value: 'us-east-2', label: 'US East (Ohio)' },
		{ value: 'us-west-1', label: 'US West (N. California)' },
		{ value: 'us-west-2', label: 'US West (Oregon)' },
		{ value: 'eu-west-1', label: 'EU West (Ireland)' },
		{ value: 'eu-central-1', label: 'EU Central (Frankfurt)' },
		{ value: 'ap-northeast-1', label: 'Asia Pacific (Tokyo)' }
	];

	// Form validation
	function validateForm() {
		errors = {};

		if (!clusterName) {
			errors.clusterName = 'Cluster name is required';
		} else if (clusterName.length < 3) {
			errors.clusterName = 'Cluster name must be at least 3 characters';
		} else if (clusterName.length > 40) {
			errors.clusterName = 'Cluster name cannot exceed 40 characters';
		} else if (!/^[a-z0-9-]+$/.test(clusterName)) {
			errors.clusterName = 'Cluster name can only contain lowercase letters, numbers, and hyphens';
		}

		if (clusterType === 'eks' && (!nodeCount || nodeCount < 1 || nodeCount > 10)) {
			errors.nodeCount = 'Node count must be between 1 and 10';
		}

		if (!region) {
			errors.region = 'Region is required';
		}

		return Object.keys(errors).length === 0;
	}

	// Handle form submission
	async function handleSubmit() {
		if (!validateForm()) return;

		isSubmitting = true;

		try {
			// In real implementation, this would be an API call
			// const response = await fetch('/api/clusters', {
			//   method: 'POST',
			//   headers: { 'Content-Type': 'application/json' },
			//   body: JSON.stringify({
			//     cluster_type: clusterType,
			//     cluster_name: clusterName,
			//     node_count: clusterType === 'eks' ? nodeCount : undefined,
			//     region: region
			//   })
			// });
			// const data = await response.json();

			// Mock response
			await new Promise((resolve) => setTimeout(resolve, 1500));

			// Generate a mock request ID
			const requestId = Math.random().toString(36).substring(2, 15);

			// Show success message
			alert(`Cluster provisioning initiated for "${clusterName}"`);

			// Redirect to status page (in a real app)
			// goto(`/clusters/status?request_id=${requestId}&cluster_name=${clusterName}`);

			// For now, just go back to clusters list
			goto('/clusters');
		} catch (error) {
			alert(`Error creating cluster: ${error.message}`);
		} finally {
			isSubmitting = false;
		}
	}
</script>

// src/routes/clusters/create/+page.svelte
<div class="mx-auto max-w-2xl">
	<button
		class="mb-6 flex items-center text-gray-600 hover:text-gray-900"
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
		Back
	</button>

	<div class="overflow-hidden rounded-lg border bg-white shadow-sm">
		<div class="border-b p-4">
			<h1 class="text-xl font-bold">Create a new EKS Cluster</h1>
			<p class="text-gray-600">Provision a new Amazon EKS cluster with Crossplane</p>
		</div>
		<div class="p-6">
			<form on:submit|preventDefault={handleSubmit} class="space-y-6">
				<div class="space-y-2">
					<label class="block text-sm font-medium text-gray-700">Cluster Type</label>
					<div class="space-y-2">
						<div class="flex items-center">
							<input
								id="eks"
								name="clusterType"
								type="radio"
								class="text-primary-600 focus:ring-primary-500 h-4 w-4"
								bind:group={clusterType}
								value="eks"
							/>
							<label for="eks" class="ml-3 block text-sm font-normal text-gray-700">
								EKS with Managed Node Groups
							</label>
						</div>
						<div class="flex items-center">
							<input
								id="fargate"
								name="clusterType"
								type="radio"
								class="text-primary-600 focus:ring-primary-500 h-4 w-4"
								bind:group={clusterType}
								value="fargate"
							/>
							<label for="fargate" class="ml-3 block text-sm font-normal text-gray-700">
								EKS with Fargate (Serverless)
							</label>
						</div>
					</div>
					<p class="text-sm text-gray-500">
						{clusterType === 'eks'
							? 'Traditional Kubernetes infrastructure with EC2 instances'
							: 'Serverless Kubernetes without managing EC2 instances'}
					</p>
				</div>

				<div class="space-y-1">
					<label for="clusterName" class="block text-sm font-medium text-gray-700"
						>Cluster Name</label
					>
					<input
						id="clusterName"
						type="text"
						bind:value={clusterName}
						placeholder="my-eks-cluster"
						class="focus:ring-primary-500 focus:border-primary-500 w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:ring-1 focus:outline-none"
					/>
					<p class="text-sm text-gray-500">
						A unique name for your cluster (lowercase letters, numbers, and hyphens only)
					</p>
					{#if errors.clusterName}
						<p class="text-sm text-red-600">{errors.clusterName}</p>
					{/if}
				</div>

				{#if clusterType === 'eks'}
					<div class="space-y-1">
						<label for="nodeCount" class="block text-sm font-medium text-gray-700">Node Count</label
						>
						<input
							id="nodeCount"
							type="number"
							min="1"
							max="10"
							bind:value={nodeCount}
							class="focus:ring-primary-500 focus:border-primary-500 w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:ring-1 focus:outline-none"
						/>
						<p class="text-sm text-gray-500">Number of worker nodes to provision (1-10)</p>
						{#if errors.nodeCount}
							<p class="text-sm text-red-600">{errors.nodeCount}</p>
						{/if}
					</div>
				{/if}

				<div class="space-y-1">
					<label for="region" class="block text-sm font-medium text-gray-700">AWS Region</label>
					<select
						id="region"
						bind:value={region}
						class="focus:ring-primary-500 focus:border-primary-500 w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:ring-1 focus:outline-none"
					>
						{#each regions as region}
							<option value={region.value}>{region.label}</option>
						{/each}
					</select>
					<p class="text-sm text-gray-500">The AWS region where your cluster will be deployed</p>
					{#if errors.region}
						<p class="text-sm text-red-600">{errors.region}</p>
					{/if}
				</div>

				<button
					type="submit"
					class="bg-primary-600 hover:bg-primary-700 focus:ring-primary-500 w-full rounded-md px-4 py-2 font-medium text-white focus:ring-2 focus:ring-offset-2 focus:outline-none disabled:cursor-not-allowed disabled:opacity-50"
					disabled={isSubmitting}
				>
					{#if isSubmitting}
						<span class="flex items-center justify-center">
							<svg
								class="mr-3 -ml-1 h-5 w-5 animate-spin text-white"
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
							Provisioning...
						</span>
					{:else}
						Create Cluster
					{/if}
				</button>
			</form>
		</div>
	</div>
</div>
