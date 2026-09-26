output "vpc_id" {
  value = module.vpc.vpc_id
}

output "api_public_ip" {
  value = module.api_server.public_ip
}

output "db_endpoint" {
  value = module.database.db_endpoint
}