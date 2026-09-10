#!/bin/bash
set -euo pipefail

exec > >(tee -a /var/log/technova-setup.log) 2>&1

yum update -y
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs git

mkdir -p /opt/technova-api
cd /opt/technova-api

cat > package.json <<'JSON'
{"name":"technova-api","version":"1.0.0","private":true,"dependencies":{"express":"^4.18.3"}}
JSON

cat > server.js <<'NODE'
const express = require('express');
const os = require('os');

const app = express();
const port = 3000;

app.get('/', (_request, response) => {
  response.json({ message: 'TechNova API - Rodando na AWS!', hostname: os.hostname() });
});

app.get('/health', (_request, response) => {
  response.json({ status: 'healthy', service: 'technova-api' });
});

app.get('/orders', (_request, response) => {
  response.json({ orders: [{ id: 1, product: 'Widget A', status: 'shipped' }] });
});

app.listen(port, '0.0.0.0', () => console.log(`API listening on ${port}`));
NODE

npm install --omit=dev
nohup node server.js > /var/log/technova-api.log 2>&1 &
echo "TechNova API iniciada."
