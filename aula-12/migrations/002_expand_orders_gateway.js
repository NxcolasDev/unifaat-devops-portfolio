'use strict';

const id = '002_expand_orders_gateway';

async function up(client) {
  await client.query(
    'ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_gateway TEXT'
  );
}

async function down(client) {
  await client.query('ALTER TABLE orders DROP COLUMN IF EXISTS payment_gateway');
}

async function verify(client) {
  const result = await client.query(
    `SELECT 1
       FROM information_schema.columns
      WHERE table_schema = current_schema()
        AND table_name = 'orders'
        AND column_name = 'payment_gateway'`
  );
  return result.rowCount === 1;
}

module.exports = { down, id, up, verify };
