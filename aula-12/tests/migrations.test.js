'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { newDb } = require('pg-mem');
const { getStatus, runDown, runUp } = require('../migrations/runner');

async function createDatabase() {
  const database = newDb({ noAstCoverageCheck: true });
  const { Pool } = database.adapters.createPg();
  const pool = new Pool();
  await pool.query(`
    CREATE TABLE orders (
      id SERIAL PRIMARY KEY,
      product TEXT NOT NULL
    )
  `);
  await pool.query("INSERT INTO orders (product) VALUES ('book')");
  return pool;
}

test('migrations apply in order, can roll back one at a time, and preserve existing order data', async () => {
  const pool = await createDatabase();
  const client = await pool.connect();
  try {
    assert.deepEqual(await runUp(client), [
      '001_expand_orders_currency',
      '002_expand_orders_gateway'
    ]);
    assert.deepEqual((await getStatus(client)).map(({ applied }) => applied), [true, true]);

    assert.equal(await runDown(client), '002_expand_orders_gateway');
    assert.deepEqual((await getStatus(client)).map(({ applied }) => applied), [true, false]);

    assert.equal(await runDown(client), '001_expand_orders_currency');
    assert.deepEqual((await getStatus(client)).map(({ applied }) => applied), [false, false]);

    const result = await client.query('SELECT id, product FROM orders');
    assert.deepEqual(result.rows, [{ id: 1, product: 'book' }]);
  } finally {
    client.release();
    await pool.end();
  }
});

test('running up twice is idempotent', async () => {
  const pool = await createDatabase();
  const client = await pool.connect();
  try {
    await runUp(client);
    assert.deepEqual(await runUp(client), []);
  } finally {
    client.release();
    await pool.end();
  }
});
