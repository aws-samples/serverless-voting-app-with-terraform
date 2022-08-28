<script>
	import { onMount, beforeUpdate } from 'svelte';
	import { Chart } from 'chart.js/auto/auto';

	export let data;

	let chartLabels = data.map((v) => v.id);
	let chartValues = data.map((v) => v.votes);
	let ctx;
	let chartCanvas;
	var chart;

	onMount(async (promise) => {
		ctx = chartCanvas.getContext('2d');
		chart = new Chart(ctx, {
			type: 'bar',
			data: {
				labels: chartLabels,
				datasets: [
					{
						data: chartValues,
						backgroundColor: [
							'rgb(255, 99, 132, 0.5)',
							'rgba(255, 159, 64, 0.5)',
							'rgba(75, 192, 192, 0.5)'
						],
						borderColor: ['rgb(255, 99, 132)', 'rgba(255, 159, 64)', 'rgba(75, 192, 192)'],
						borderWidth: 1,
						barPercentage: 0.5
					}
				]
			},
			options: {
				animation: true,
				maintainAspectRatio: false,
				indexAxis: 'x',
				plugins:{
					legend: {
						display: false
					}
				}
			}
		});
	});

	beforeUpdate(async (promise) => {
		if (!chart) return;

		console.log('update chart data = ' + data.map((v) => v.votes));

		data
			.map((v) => v.votes)
			.forEach((value, i) => {
				chart.data.datasets[0].data[i] = value;
			});

		chart.update();
	});
</script>

<canvas bind:this={chartCanvas} />
