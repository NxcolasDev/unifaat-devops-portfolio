output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value = [
    for k, v in aws_subnet.subnets : v.id if var.subnets[k].type == "public"
  ]
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value = [
    for k, v in aws_subnet.subnets : v.id if var.subnets[k].type == "private"
  ]
}