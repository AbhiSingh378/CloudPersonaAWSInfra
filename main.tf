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

module "ec2" {
  source            = "./modules/ec2"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.subnets.public_subnet_ids
  ami_id            = var.ami_name
  project_name      = var.project_name
}