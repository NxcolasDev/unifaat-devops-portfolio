'use strict';

const { publishMetrics } = require('./metrics');

function createMetricsMiddleware(client) {
  return (request, response, next) => {
    const startedAt = process.hrtime.bigint();
    response.once('finish', () => {
      const responseTimeMs = Number(process.hrtime.bigint() - startedAt) / 1e6;
      const error5xx = response.statusCode >= 500 ? 1 : 0;
      const ordersCreated = request.method === 'POST' &&
        request.path === '/orders' &&
        response.statusCode === 201 ? 1 : 0;

      publishMetrics(client, { responseTimeMs, error5xx, ordersCreated })
        .catch((error) => {
          console.error('CloudWatch metric publication failed:', error);
        });
    });
    next();
  };
}

module.exports = { createMetricsMiddleware };
