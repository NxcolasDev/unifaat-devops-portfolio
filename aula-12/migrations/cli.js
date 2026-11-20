'use strict';

const { Pool } = require('pg');
const { getStatus, runDown, runUp } = require('./runner');

async function main() {
  const command = process.argv[2];
  if (!['up', 'down', 'status'].includes(command)) {
    throw new Error('Usage: npm run migrate -- up|down|status');
  }
  if (!process.env.DATABASE_URL) {
    throw new Error('DATABASE_URL must be set.');
  }

  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const client = await pool.connect();
  try {
    if (command === 'up') {
      const completed = await runUp(client);
      console.log(completed.length ? `Applied: ${completed.join(', ')}` : 'No pending migrations.');
    } else if (command === 'down') {
      const rolledBack = await runDown(client);
      console.log(rolledBack ? `Rolled back: ${rolledBack}` : 'No migration to roll back.');
    } else {
      const status = await getStatus(client);
      for (const migration of status) {
        console.log(`${migration.applied ? 'applied' : 'pending'} ${migration.id}`);
      }
    }
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch((error) => {
  console.error('Migration command failed:', error);
  process.exitCode = 1;
});
