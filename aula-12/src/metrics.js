'use strict';

const { PutMetricDataCommand } = require('@aws-sdk/client-cloudwatch');

function buildMetricData({ responseTimeMs, error5xx, ordersCreated, timestamp = new Date() }) {
  const values = { responseTimeMs, error5xx, ordersCreated };
  for (const [name, value] of Object.entries(values)) {
    if (!Number.isFinite(value) || value < 0) {
      throw new TypeError(`${name} must be a non-negative finite number.`);
    }
  }

  return [
    { MetricName: 'ResponseTime', Unit: 'Milliseconds', Value: responseTimeMs },
    { MetricName: 'Error5xx', Unit: 'Count', Value: error5xx },
    { MetricName: 'OrdersCreated', Unit: 'Count', Value: ordersCreated }
  ].map((metric) => ({
    ...metric,
    Timestamp: timestamp,
    Dimensions: [{ Name: 'Service', Value: 'TechNovaAPI' }]
  }));
}

async function publishMetrics(client, data) {
  const command = new PutMetricDataCommand({
    Namespace: 'TechNova/API',
    MetricData: buildMetricData(data)
  });
  return client.send(command);
}

module.exports = { buildMetricData, publishMetrics };
