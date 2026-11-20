data "aws_iam_role" "lab_role" {
  name = var.lambda_role_name
}

resource "aws_lambda_function" "aiops" {
  function_name    = "technova-aula12-aiops"
  filename         = "${path.module}/../lambda-aiops/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda-aiops/function.zip")
  role             = data.aws_iam_role.lab_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 15
  memory_size      = 128

  environment {
    variables = {
      AWS_REGION      = var.aws_region
      BEDROCK_MODEL_ID = var.bedrock_model_id
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "error5xx_fixed" {
  alarm_name          = "TechNova-Error5xx"
  alarm_description   = "Fixed threshold for TechNova API server errors."
  namespace           = "TechNova/API"
  metric_name         = "Error5xx"
  statistic           = "Sum"
  period              = var.alarm_period_seconds
  evaluation_periods  = 2
  threshold           = var.error5xx_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    Service = "TechNovaAPI"
  }

  alarm_actions = []
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "response_time_anomaly" {
  alarm_name          = "TechNova-ResponseTime-Anomaly"
  alarm_description   = "Anomaly-detection band for TechNova API response time."
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 2
  threshold           = 0
  threshold_metric_id = "ad1"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "m1"
    return_data = false

    metric {
      metric_name = "ResponseTime"
      namespace   = "TechNova/API"
      period      = var.alarm_period_seconds
      stat        = "Average"

      dimensions = {
        Service = "TechNovaAPI"
      }
    }
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "ResponseTime expected range"
    return_data = true
  }

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "alarm_to_aiops" {
  name        = "technova-aula12-alarm-to-aiops"
  description = "Send TechNova CloudWatch alarm transitions to the AIOps Lambda."

  event_pattern = jsonencode({
    source        = ["aws.cloudwatch"]
    "detail-type" = ["CloudWatch Alarm State Change"]
    detail = {
      state = {
        value = ["ALARM"]
      }
      alarmName = [
        aws_cloudwatch_metric_alarm.error5xx_fixed.alarm_name,
        aws_cloudwatch_metric_alarm.response_time_anomaly.alarm_name
      ]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "aiops" {
  rule      = aws_cloudwatch_event_rule.alarm_to_aiops.name
  target_id = "technova-aiops-lambda"
  arn       = aws_lambda_function.aiops.arn
}

resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowTechNovaCloudWatchAlarmEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aiops.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alarm_to_aiops.arn
}

output "aiops_lambda_name" {
  value       = aws_lambda_function.aiops.function_name
  description = "AIOps analysis Lambda name."
}

output "error_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.error5xx_fixed.alarm_name
  description = "Fixed-threshold server error alarm."
}

output "anomaly_alarm_name" {
  value       = aws_cloudwatch_metric_alarm.response_time_anomaly.alarm_name
  description = "Response-time anomaly detection alarm."
}
