'use strict';

function extractAlarmContext(event) {
  const detail = event.detail || {};
  const state = detail.state || {};
  return {
    alarmName: detail.alarmName || 'unknown-alarm',
    reason: state.reason || 'No alarm reason was provided.',
    state: state.value || 'UNKNOWN',
    timestamp: state.timestamp || new Date().toISOString(),
    region: event.region || process.env.AWS_REGION || 'us-east-1'
  };
}

function analyzeLocally(context) {
  const text = `${context.alarmName} ${context.reason}`.toLowerCase();
  const gatewayRelated = text.includes('payment') || text.includes('gateway');
  return {
    severity: context.state === 'ALARM' ? 'P1' : 'P3',
    probableRootCause: gatewayRelated
      ? 'Payment gateway timeout or degradation is likely; confirm against API logs and request metrics.'
      : 'The alarm threshold was crossed; correlate API latency, 5xx errors and order volume before assigning a root cause.',
    immediateAction: gatewayRelated
      ? 'Disable FF_PAYMENT_GATEWAY_V2, inspect gateway timeouts and pause rollout promotion.'
      : 'Check target health and recent deployments; use the deploy runbook before changing production.',
    rollbackRequired: gatewayRelated,
    humanApprovalRequired: true,
    source: 'rules'
  };
}

async function analyzeWithBedrock(context) {
  const { BedrockRuntimeClient, ConverseCommand } =
    require('@aws-sdk/client-bedrock-runtime');
  const client = new BedrockRuntimeClient({
    region: process.env.AWS_REGION || 'us-east-1'
  });
  const response = await client.send(new ConverseCommand({
    modelId: process.env.BEDROCK_MODEL_ID,
    system: [{
      text: 'Analyze operational alarms conservatively. Never claim certainty. Return severity, probableRootCause, immediateAction, rollbackRequired, and humanApprovalRequired as JSON. Do not request or reveal secrets.'
    }],
    messages: [{
      role: 'user',
      content: [{ text: JSON.stringify(context) }]
    }],
    inferenceConfig: { maxTokens: 400, temperature: 0 }
  }));
  const text = response.output && response.output.message &&
    response.output.message.content &&
    response.output.message.content.map((item) => item.text || '').join('\n');

  if (!text) {
    throw new Error('Bedrock returned an empty operational analysis.');
  }

  return { analysis: text, source: 'bedrock', humanApprovalRequired: true };
}

async function handler(event) {
  const context = extractAlarmContext(event || {});
  const analysis = process.env.BEDROCK_MODEL_ID
    ? await analyzeWithBedrock(context)
    : analyzeLocally(context);
  const result = { ...context, ...analysis };
  console.log(JSON.stringify(result));
  return result;
}

module.exports = { analyzeLocally, extractAlarmContext, handler };
