'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { buildMetricData } = require('../src/metrics');

test('builds the three documented TechNova CloudWatch metrics', () => {
  const timestamp = new Date('2026-11-19T12:00:00Z');
  const metrics = buildMetricData({
    responseTimeMs: 120,
    error5xx: 0,
    ordersCreated: 3,
    timestamp
  });

  assert.deepEqual(metrics.map((metric) => metric.MetricName), [
    'ResponseTime',
    'Error5xx',
    'OrdersCreated'
  ]);
  assert.ok(metrics.every((metric) => metric.Timestamp === timestamp));
  assert.ok(metrics.every((metric) => metric.Dimensions[0].Value === 'TechNovaAPI'));
});

test('rejects invalid metric values', () => {
  assert.throws(() => buildMetricData({
    responseTimeMs: -1,
    error5xx: 0,
    ordersCreated: 0
  }), TypeError);
});
