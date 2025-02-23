import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';
import adapter from '@sveltejs/adapter-static';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		adapter: adapter({
			pages: 'build',
			assets: 'build',
			fallback: null,
			precompress: false
		}),
		prerender: {
			handleMissingId: 'ignore'
		}
	},

	preprocess: [
		vitePreprocess({
			postcss: {
				configFilePath: './postcss.config.cjs'
			},
			style: {
				onwarn: (warning) => {
					console.warn('Svelte style warning:', warning);
				}
			}
		})
	],

	compilerOptions: {
		dev: true,
		css: "injected" // 更新为新的 CSS 选项值
	},

	onwarn: (warning, handler) => {
		console.log('Svelte warning:', warning);
		handler(warning);
	}
};

export default config;
