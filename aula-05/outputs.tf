output "vpc_id" {
  value = aws_vpc.main.id
}

output "ec2_public_ip" {
  value = aws_instance.api.public_ip
}

output "rds_address" {
  value = aws_db_instance.main.address
}

output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "rds_database_name" {
  value = aws_db_instance.main.db_name
}

output "connection_command" {
  value = "psql -h ${aws_db_instance.main.address} -U ${var.db_username} -d ${var.db_name} -p 5432"
}