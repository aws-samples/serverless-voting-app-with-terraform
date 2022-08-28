import { sveltekit } from '@sveltejs/kit/vite';

/** @type {import('vite').UserConfig} */
const config = {
	resolve: { 
		alias: { mqtt: 'mqtt/dist/mqtt.min', }, 
	},
	plugins: [
		sveltekit()
	]
};

export default config;
