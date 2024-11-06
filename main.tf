provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
}

module "subnets" {
  source               = "./modules/subnets"
  vpc_id               = module.vpc.vpc_id
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  project_name         = var.project_name
}

module "internet_gateway" {
  source       = "./modules/internet_gateway"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}

module "route_tables" {
  source              = "./modules/route_tables"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids
  project_name        = var.project_name
}

# First create RDS module
module "rds" {
  source                = "./modules/rds"
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.subnets.private_subnet_ids
  app_security_group_id = module.ec2.app_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  db_engine             = var.db_engine
  db_engine_version     = var.db_engine_version
}

# Then create EC2 module with RDS information
module "ec2" {
  source               = "./modules/ec2"
  vpc_id               = module.vpc.vpc_id
  vpc_cidr             = var.vpc_cidr
  public_subnet_ids    = module.subnets.public_subnet_ids
  ami_id               = var.ami_name
  project_name         = var.project_name
  instance_type        = var.instance_type
  iam_instance_profile = module.iam.instance_profile_name
  route53_zone_id      = var.route53_zone_id
  s3_bucket_name       = module.s3.bucket_name
  aws_region           = var.aws_region
  domain_name          = var.domain_name
  environment          = var.environment
  db_endpoint          = module.rds.db_instance_endpoint
  db_username          = var.db_username
  db_password          = var.db_password
  db_name              = var.db_name
}

module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  bucket_arn   = module.s3.bucket_arn
}


