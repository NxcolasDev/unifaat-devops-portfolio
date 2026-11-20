'use strict';

const migrations = [
  require('./001_expand_orders_currency'),
  require('./002_expand_orders_gateway')
];

async function ensureMigrationTable(client) {
  await client.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      id TEXT PRIMARY KEY,
      executed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);
}

async function appliedMigrations(client) {
  const result = await client.query(
    'SELECT id FROM schema_migrations ORDER BY id'
  );
  return new Set(result.rows.map((row) => row.id));
}

async function runUp(client) {
  await ensureMigrationTable(client);
  const applied = await appliedMigrations(client);
  const completed = [];

  for (const migration of migrations) {
    if (applied.has(migration.id)) {
      continue;
    }

    await client.query('BEGIN');
    try {
      await migration.up(client);
      if (!(await migration.verify(client))) {
        throw new Error(`Migration verification failed: ${migration.id}`);
      }
      await client.query('INSERT INTO schema_migrations (id) VALUES ($1)', [migration.id]);
      await client.query('COMMIT');
      completed.push(migration.id);
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    }
  }

  return completed;
}

async function runDown(client) {
  await ensureMigrationTable(client);
  const applied = await appliedMigrations(client);
  const migration = [...migrations].reverse()
    .find((candidate) => applied.has(candidate.id));

  if (!migration) {
    return null;
  }

  await client.query('BEGIN');
  try {
    await migration.down(client);
    if (await migration.verify(client)) {
      throw new Error(`Rollback verification failed: ${migration.id}`);
    }
    await client.query('DELETE FROM schema_migrations WHERE id = $1', [migration.id]);
    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  }

  return migration.id;
}

async function getStatus(client) {
  await ensureMigrationTable(client);
  const applied = await appliedMigrations(client);
  return migrations.map((migration) => ({
    id: migration.id,
    applied: applied.has(migration.id)
  }));
}

module.exports = { getStatus, runDown, runUp };
