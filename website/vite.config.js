import { sveltekit } from '@sveltejs/kit/vite';

/** @type {import('vite').UserConfig} */
const config = {
	resolve: { 
		alias: { mqtt: 'mqtt/dist/mqtt.min' }, 
	},
	plugins: [
		sveltekit()
	],
	optimizeDeps: {
		include: ['mqtt', '@smithy/signature-v4', '@aws-crypto/sha256-js', '@smithy/protocol-http'],
		esbuildOptions: {
			define: {
				global: 'globalThis'
			}
		}
	},
	server: {
		host: '0.0.0.0',
		allowedHosts: ['.vfs.cloud9.us-west-2.amazonaws.com'],
		fs: {
			strict: false
		}
	}
};

export default config;
