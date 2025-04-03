<script>
	import ArrowRight from 'svelte-icons/bi/BiArrowRight.svelte';
	import Server from 'svelte-icons/bi/BiServer.svelte';
	import Cloud from 'svelte-icons/bi/BiCloud.svelte';
</script>

// src/routes/+page.svelte
<section class="flex flex-col items-center space-y-8 py-10 text-center">
	<h1 class="text-4xl font-bold tracking-tight">Welcome to the EKS Self-Service Portal</h1>
	<p class="max-w-3xl text-xl text-gray-600">
		Easily provision and manage your Amazon EKS clusters without needing to understand the
		underlying Kubernetes or AWS infrastructure.
	</p>
	<div class="flex gap-4">
		<a
			href="/clusters/create"
			class="bg-primary-600 hover:bg-primary-700 rounded-md px-6 py-3 text-lg font-medium text-white"
		>
			Create a Cluster
		</a>
		<a
			href="/clusters"
			class="border-primary-600 text-primary-600 hover:bg-primary-50 rounded-md border px-6 py-3 text-lg font-medium"
		>
			View Your Clusters
		</a>
	</div>
</section>

<section class="grid grid-cols-1 gap-8 py-10 md:grid-cols-2">
	<!-- EKS Card -->
	<div class="overflow-hidden rounded-lg border bg-white shadow-sm">
		<div class="border-b p-4">
			<div class="flex items-center space-x-2">
				<div class="text-primary-600 h-6 w-6">
					<Server />
				</div>
				<h3 class="text-xl font-bold">EKS Managed Node Groups</h3>
			</div>
			<p class="text-gray-600">Traditional Kubernetes infrastructure with EC2 instances</p>
		</div>
		<div class="p-4">
			<p>
				Amazon EKS managed node groups automate the provisioning and lifecycle management of nodes
				for Amazon EKS Kubernetes clusters.
			</p>
			<ul class="mt-4 space-y-2">
				<li class="flex items-center">
					<div class="mr-2 h-4 w-4 text-green-500">
						<ArrowRight />
					</div>
					<span>Full control over your Kubernetes infrastructure</span>
				</li>
				<li class="flex items-center">
					<div class="mr-2 h-4 w-4 text-green-500">
						<ArrowRight />
					</div>
					<span>Customizable node sizes and configurations</span>
				</li>
				<li class="flex items-center">
					<div class="mr-2 h-4 w-4 text-green-500">
						<ArrowRight />
					</div>
					<span>Built-in integration with AWS IAM roles for service accounts</span>
				</li>
			</ul>
		</div>
		<div class="border-t bg-gray-50 p-4">
			<a
				href="/clusters/create?type=eks"
				class="bg-primary-600 hover:bg-primary-700 inline-block rounded-md px-4 py-2 font-medium text-white"
			>
				Create EKS Cluster
			</a>
		</div>
	</div>

	<!-- Fargate Card -->
	<div class="overflow-hidden rounded-lg border bg-white shadow-sm">
		<div class="border-b p-4">
			<div class="flex items-center space-x-2">
				<div class="text-primary-600 h-6 w-6">
					<Cloud />
				</div>
				<h3 class="text-xl font-bold">EKS Fargate</h3>
			</div>
			<p class="text-gray-600">Serverless Kubernetes without managing EC2 instances</p>
		</div>
		<div class="p-4">
			<p>
				With AWS Fargate, you can run Kubernetes pods without managing servers or clusters of Amazon
				EC2 instances.
			</p>
			<ul class="mt-4 space-y-2">
				<li class="flex items-center">
					<div class="mr-2 h-4 w-4 text-green-500">
						<ArrowRight />
					</div>
					<span>No node management required - fully serverless</span>
				</li>
				<li class="flex items-center">
					<div class="mr-2 h-4 w-4 text-green-500">
						<ArrowRight />
					</div>
					<span>Pay only for the resources each pod uses</span>
				</li>
				<li class="flex items-center">
					<div class="mr-2 h-4 w-4 text-green-500">
						<ArrowRight />
					</div>
					<span>Each pod is isolated in its own VM-like environment</span>
				</li>
			</ul>
		</div>
		<div class="border-t bg-gray-50 p-4">
			<a
				href="/clusters/create?type=fargate"
				class="bg-primary-600 hover:bg-primary-700 inline-block rounded-md px-4 py-2 font-medium text-white"
			>
				Create Fargate Cluster
			</a>
		</div>
	</div>
</section>

<section class="mt-10 rounded-lg border p-6">
	<h2 class="mb-4 text-2xl font-bold">How It Works</h2>
	<div class="grid grid-cols-1 gap-6 md:grid-cols-3">
		<div class="flex flex-col items-center text-center">
			<div class="bg-primary-100 mb-4 rounded-full p-4">
				<span class="text-primary-600 text-2xl font-bold">1</span>
			</div>
			<h3 class="mb-2 text-lg font-medium">Select Your Cluster Type</h3>
			<p class="text-gray-600">Choose between EKS with managed node groups or serverless Fargate</p>
		</div>

		<div class="flex flex-col items-center text-center">
			<div class="bg-primary-100 mb-4 rounded-full p-4">
				<span class="text-primary-600 text-2xl font-bold">2</span>
			</div>
			<h3 class="mb-2 text-lg font-medium">Configure Options</h3>
			<p class="text-gray-600">
				Provide a name, select a region, and set basic configuration parameters
			</p>
		</div>

		<div class="flex flex-col items-center text-center">
			<div class="bg-primary-100 mb-4 rounded-full p-4">
				<span class="text-primary-600 text-2xl font-bold">3</span>
			</div>
			<h3 class="mb-2 text-lg font-medium">Deploy & Access</h3>
			<p class="text-gray-600">
				Your cluster is created through Crossplane and a kubeconfig is provided for access
			</p>
		</div>
	</div>
</section>
