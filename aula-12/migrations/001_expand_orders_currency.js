'use strict';

const id = '001_expand_orders_currency';

async function up(client) {
  await client.query(
    "ALTER TABLE orders ADD COLUMN IF NOT EXISTS currency TEXT NOT NULL DEFAULT 'USD'"
  );
}

async function down(client) {
  await client.query('ALTER TABLE orders DROP COLUMN IF EXISTS currency');
}

async function verify(client) {
  const result = await client.query(
    `SELECT 1
       FROM information_schema.columns
      WHERE table_schema = current_schema()
        AND table_name = 'orders'
        AND column_name = 'currency'`
  );
  return result.rowCount === 1;
}

module.exports = { down, id, up, verify };
