'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { analyzeLocally, extractAlarmContext } = require('./index');

const scenarioPath = process.argv[2] ||
  path.join(__dirname, 'scenarios', 'payment-gateway-timeout.json');

const event = JSON.parse(fs.readFileSync(scenarioPath, 'utf8'));
const context = extractAlarmContext(event);
const result = { ...context, ...analyzeLocally(context) };
console.log(JSON.stringify(result, null, 2));
