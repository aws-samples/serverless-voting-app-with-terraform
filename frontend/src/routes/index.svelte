<script>
	import Vote from "$lib/components/Vote.svelte"
	import Chart from "$lib/components/Chart.svelte"

	let pets = [
		{name: 'dog', votes: 0},
		{name: 'cat', votes: 0},
		{name: 'bird', votes: 0}
	]

</script>

<svelte:head>
  <title>Serverless Polling App</title>
</svelte:head>

<div class="flex flex-col md:flex-row basic-2 my-4 justify-between items-end">
  <h1 class="text-4xl font-bold">What is your favorite pet?</h1>
  <p class="px-2">Total votes: {pets.map(p => p.votes).reduce((x, y) => x + y)}</p>
</div>

<div class="flex flex-col md:flex-row">
	{#each pets as pet}
		<Vote vote={pet.name} bind:value={pet.votes} />
	{/each}
</div>

<div class="h-96 shadow-xl my-2 bg-base-100 rounded-2xl p-5">
	<Chart data={pets} />
</div>

