'use strict';

const express = require('express');
const { getEnabledFlags, isEnabled } = require('./feature-flags');
const { createMetricsMiddleware } = require('./metrics-middleware');

function createApp({ env = process.env, metricsClient } = {}) {
  const app = express();
  app.use(express.json());
  if (metricsClient) {
    app.use(createMetricsMiddleware(metricsClient));
  }

  app.get('/health', (_request, response) => {
    response.json({ status: 'ok', service: 'technova-api' });
  });

  app.get('/flags', (_request, response) => {
    if (env.NODE_ENV === 'production') {
      return response.sendStatus(404);
    }

    return response.json(getEnabledFlags(env));
  });

  app.post('/orders', (request, response) => {
    const { product, quantity } = request.body || {};
    if (typeof product !== 'string' || product.trim() === '' ||
        !Number.isInteger(quantity) || quantity < 1) {
      return response.status(400).json({
        error: 'product and a positive integer quantity are required'
      });
    }

    const useGatewayV2 = isEnabled('PAYMENT_GATEWAY_V2', env);
    return response.status(201).json({
      order: {
        id: `order-${Date.now()}`,
        product,
        quantity,
        paymentGateway: useGatewayV2 ? 'v2' : 'legacy'
      }
    });
  });

  return app;
}

module.exports = { createApp };
