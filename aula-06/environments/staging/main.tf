module "vpc" {
  source       = "../../modules/vpc"
  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
  subnets      = var.subnets
}

module "api_sg" {
  source       = "../../modules/security-group"
  name         = "technova-${var.environment}-api-sg"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name

  ingress_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "HTTP" },
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "SSH" }
  ]
}

module "rds_sg" {
  source       = "../../modules/security-group"
  name         = "technova-${var.environment}-rds-sg"
  vpc_id       = module.vpc.vpc_id
  environment  = var.environment
  project_name = var.project_name

  ingress_rules = [
    { from_port = 5432, to_port = 5432, protocol = "tcp", security_groups = [module.api_sg.sg_id], description = "PostgreSQL da API" }
  ]
}

module "api_server" {
  source             = "../../modules/ec2"
  instance_name      = "technova-${var.environment}-api"
  ami_id             = "ami-0c02fb55956c7d316"
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [module.api_sg.sg_id]
}

module "database" {
  source             = "../../modules/rds"
  db_name            = "technova_${var.environment}"
  db_username        = var.db_username
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.rds_sg.sg_id]
  environment        = var.environment
  project_name       = var.project_name
}