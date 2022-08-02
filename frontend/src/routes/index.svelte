<script>
	import Vote from '$lib/components/Vote.svelte';
	import Chart from '$lib/components/Chart.svelte';

	import { pets } from '$lib/stores/pets.js';

	$: total_votes = $pets.map((pet) => pet.votes).reduce((total, next) => total + next, 0);
</script>

<svelte:head>
	<title>Serverless Polling App</title>
</svelte:head>

<div class="flex flex-col md:flex-row basic-2 my-4 justify-between items-end">
	<h1 class="text-3xl font-bold">What is your favorite pet?</h1>
	<p class="px-2">Total votes: {total_votes}</p>
</div>

<div class="flex flex-col md:flex-row">
	{#each $pets as pet}
		<Vote vote={pet} bind:value={pet.votes} />
	{/each}
</div>

<div class="h-96 shadow-xl my-4 bg-base-100 rounded-2xl p-5 border-4">
	<Chart data={$pets} />
</div>
