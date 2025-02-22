const mqtt = require('mqtt');
import { SignatureV4 } from '@smithy/signature-v4';
import { Sha256 } from '@aws-crypto/sha256-js';
import { HttpRequest } from '@smithy/protocol-http';
import { formatUrl } from '@aws-sdk/util-format-url';

export async function getIoTClient(iotEndpoint, region, creds) {
	const signer = new SignatureV4({
		credentials: {
			accessKeyId: creds.AccessKeyId,
			secretAccessKey: creds.SecretKey, 
		},
		region: region,
		service: 'iotdevicegateway',
		sha256: Sha256
	});

	const req = new HttpRequest({
		protocol: 'wss',
		hostname: iotEndpoint,
		path: '/mqtt',
		method: 'GET',
		headers: { host: iotEndpoint }
	});

	const request = await signer.presign(req, { expiresIn: 3600 });

	if (creds.SessionToken) {
		request.query['X-Amz-Security-Token'] = creds.SessionToken;
	}
	const iot_url = formatUrl(request);

	console.log(iot_url);

	return mqtt.connect(iot_url, {
		clientId: "serverless-voting-client-"+Math.random().toString(36).substring(2,8),
		protocolVersion: 4,
	});
}
