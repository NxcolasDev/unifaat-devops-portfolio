output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = aws_lb.api.dns_name
}

output "listener_arn" {
  description = "Listener ARN used by the canary rollout script."
  value       = aws_lb_listener.http.arn
}

output "stable_tg_arn" {
  description = "Stable target group ARN."
  value       = aws_lb_target_group.stable.arn
}

output "canary_tg_arn" {
  description = "Canary target group ARN."
  value       = aws_lb_target_group.canary.arn
}

output "alb_security_group_id" {
  description = "Security group attached to the ALB."
  value       = aws_security_group.alb.id
}
