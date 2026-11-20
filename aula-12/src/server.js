'use strict';

const { createApp } = require('./app');

const port = Number(process.env.PORT || 3000);
let metricsClient;
if (process.env.PUBLISH_CLOUDWATCH_METRICS === 'true') {
  const { CloudWatchClient } = require('@aws-sdk/client-cloudwatch');
  metricsClient = new CloudWatchClient({
    region: process.env.AWS_REGION || 'us-east-1'
  });
}
const app = createApp({ metricsClient });
const server = app.listen(port, '0.0.0.0', () => {
  console.log(`TechNova API listening on ${port}`);
});

function shutdown() {
  server.close((error) => {
    if (error) {
      console.error('Failed to close HTTP server cleanly:', error);
      process.exitCode = 1;
    }
  });
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
