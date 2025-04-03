<script>
	import '../app.css';
</script>

// src/routes/+layout.svelte
<div class="flex min-h-screen flex-col">
	<nav class="bg-primary-600 p-4 text-white">
		<div class="container mx-auto flex items-center justify-between">
			<a href="/" class="text-2xl font-bold">EKS Self-Service Portal</a>
			<div class="space-x-4">
				<a href="/clusters" class="hover:text-primary-200">Clusters</a>
				<a href="/clusters/create" class="hover:text-primary-200">Create Cluster</a>
			</div>
		</div>
	</nav>

	<main class="container mx-auto flex-grow px-4 py-8">
		<slot />
	</main>

	<footer class="bg-gray-100 py-6">
		<div class="container mx-auto px-4 text-center text-gray-600">
			© 2025 EKS Self-Service Portal | Powered by SvelteKit and Crossplane
		</div>
	</footer>
</div>
