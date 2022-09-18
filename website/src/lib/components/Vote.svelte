<script>
	export let vote;
	export let value;

	import { save_vote } from '$lib/stores/votes.js';

	async function count_vote() {
		value += 1;
		const res = await save_vote(vote)
	}
</script>

<div class="card card-compact w-auto bg-base-100 shadow-xl m-2">
	<figure><img src={vote.img_url} alt={vote.id} width="432" height="288"/></figure>
	<div class="card-body">
		<div class="card-actions justify-between items-center">
			<h2 class="card-title">Votes: {new Intl.NumberFormat().format(value)}</h2>
			<button class="btn btn-primary" on:click={() => count_vote()}>I love {vote.id}s!</button>
		</div>
	</div>
</div>
