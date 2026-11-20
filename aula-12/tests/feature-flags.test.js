'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const request = require('supertest');
const { createApp } = require('../src/app');
const { getEnabledFlags, isEnabled } = require('../src/feature-flags');

test('flag values are parsed explicitly and unknown values stay disabled', () => {
  assert.equal(isEnabled('CHECKOUT', { FF_CHECKOUT: 'true' }), true);
  assert.equal(isEnabled('CHECKOUT', { FF_CHECKOUT: '1' }), true);
  assert.equal(isEnabled('CHECKOUT', { FF_CHECKOUT: 'enabled' }), false);
  assert.equal(isEnabled('CHECKOUT', {}), false);
});

test('flag names must be uppercase identifiers', () => {
  assert.throws(() => isEnabled('checkout', {}), TypeError);
});

test('orders use the selected gateway and /flags is not exposed in production', async () => {
  const response = await request(createApp({
    env: { NODE_ENV: 'test', FF_PAYMENT_GATEWAY_V2: 'true' }
  }))
    .post('/orders')
    .send({ product: 'book', quantity: 1 })
    .expect(201);

  assert.equal(response.body.order.paymentGateway, 'v2');
  await request(createApp({ env: { NODE_ENV: 'production' } }))
    .get('/flags')
    .expect(404);
});

test('invalid orders are rejected and enabled flags are inspectable outside production', async () => {
  const app = createApp({
    env: { NODE_ENV: 'test', FF_PAYMENT_GATEWAY_V2: 'false', FF_SHIPPING_V2: 'on' }
  });

  await request(app).post('/orders').send({ product: '', quantity: 0 }).expect(400);
  const response = await request(app).get('/flags').expect(200);
  assert.deepEqual(response.body, {
    FF_PAYMENT_GATEWAY_V2: false,
    FF_SHIPPING_V2: true
  });
  assert.deepEqual(getEnabledFlags({ FF_NOT_A_FLAG: 'true' }), {
    FF_NOT_A_FLAG: true
  });
});
