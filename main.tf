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
  rds_kms_key_arn = module.kms.rds_key_arn
}

# Then create EC2 module with RDS information
module "ec2" {
  source               = "./modules/ec2"
  vpc_id               = module.vpc.vpc_id
  vpc_cidr             = var.vpc_cidr
  public_subnet_ids    = module.subnets.public_subnet_ids
  ami_id               = var.ami_name
  project_name         = var.project_name
  ec2_kms_key_arn      = module.kms.ec2_key_arn
  db_secret_arn        = module.secrets.rds_secret_arn
  instance_type        = var.instance_type
  sns_topic_arn        = module.sns_lambda.sns_topic_arn
  iam_instance_profile = module.iam.instance_profile_name
  certificate_arn      = var.certificate_arn
  route53_zone_id      = var.route53_zone_id
  s3_bucket_name       = module.s3.bucket_name
  aws_region           = var.aws_region
  domain_name          = var.domain_name
  environment          = var.environment
  db_endpoint          = module.rds.db_instance_endpoint
  db_username          = var.db_username
  db_password          = var.db_password
  db_name              = var.db_name
  key_name             = var.key_name
  SECRET_TOKEN         = var.SECRET_TOKEN
  email_secret_arn     = module.secrets.email_secret_arn
}

module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
  s3_kms_key_arn = module.kms.s3_key_arn
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  bucket_arn   = module.s3.bucket_arn
  db_credentials_secret_arn          = module.secrets.rds_secret_arn
  lambda_email_credentials_secret_arn = module.secrets.email_secret_arn
  ec2_key_arn                        = module.kms.ec2_key_arn
  rds_key_arn                        = module.kms.rds_key_arn
  s3_key_arn                         = module.kms.s3_key_arn
  secrets_manager_key_arn            = module.kms.secrets_key_arn
}

module "sns_lambda" {
  source = "./modules/sns_lambda"

  environment         = var.environment
  project_name        = var.project_name
  aws_region         = var.aws_region
  
  lambda_function_path = "C:/Users/aviga/assign1/serverless/lambda_verify_user/lambda_function.zip"
  lambda_handler      = "lambda_function.lambda_handler"
  lambda_runtime      = "python3.9"
  
  db_host            = module.rds.db_instance_endpoint
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  domain_name        = var.domain_name
  SECRET_TOKEN       = var.SECRET_TOKEN
  
  verification_url   = "https://${var.environment}.${var.domain_name}/v1/user/verify"
  sender_email       = var.sender_email
  sendgrid_api_key   = var.sendgrid_api_key
  
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.subnets.private_subnet_ids
  rds_arn            = module.rds.db_instance_arn
  ec2_role_arn       = module.iam.ec2_role_arn

  email_secrets_arn = module.secrets.email_secret_arn
  secrets_kms_key_arn = module.kms.secrets_key_arn

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

module "kms" {
  source = "./modules/kms"
  tags   = var.tags
  counter = var.counter
}

module "secrets" {
  source           = "./modules/secrets"
  environment      = var.environment
  kms_key_arn      = module.kms.secrets_key_arn
  counter          = var.counter
  db_username      = var.db_username
  db_password      = var.db_password
  db_host          = module.rds.db_instance_endpoint
  sender_email     = var.sender_email
  sendgrid_api_key = var.sendgrid_api_key
  SECRET_TOKEN       = var.SECRET_TOKEN
  verification_url = "https://${var.environment}.nullisnotzero.me/v1/user/verify"
}