'use strict';

const FLAG_NAME_PATTERN = /^[A-Z][A-Z0-9_]*$/;
const ENABLED_VALUES = new Set(['1', 'true', 'on', 'yes']);

function isEnabled(name, env = process.env) {
  if (!FLAG_NAME_PATTERN.test(name)) {
    throw new TypeError('Feature flag names must be uppercase identifiers.');
  }

  return ENABLED_VALUES.has(String(env[`FF_${name}`] || '').trim().toLowerCase());
}

function getEnabledFlags(env = process.env) {
  return Object.keys(env)
    .filter((key) => key.startsWith('FF_'))
    .sort()
    .reduce((flags, key) => {
      const name = key.slice(3);
      if (!FLAG_NAME_PATTERN.test(name)) {
        return flags;
      }

      flags[key] = ENABLED_VALUES.has(String(env[key]).trim().toLowerCase());
      return flags;
    }, {});
}

module.exports = { getEnabledFlags, isEnabled };
