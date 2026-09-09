# AWS Region & Project Details
aws_region   = "eu-west-1"
environment  = "dev"
project_name = "cdec-alpha"
cluster_name = "cdec-eks-dev"

# VPC Configuration (eu-west-1 Availability Zones)
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
availability_zones   = ["eu-west-1a", "eu-west-1b"]
single_nat_gateway   = true

# EKS Cluster Configuration
kubernetes_version  = "1.34"
node_instance_types = ["c7i-flex.large"]
desired_size        = 2
min_size            = 1
max_size            = 3

cluster_endpoint_public_access       = true
cluster_endpoint_private_access      = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

cluster_admin_iam_role_names    = []
cluster_admin_principal_arns    = []
include_caller_as_cluster_admin = true

additional_tags = {
  Owner       = "platform-team"
  Environment = "dev"
  Project     = "cdec-alpha"
}

# DNS & Domains Configuration
dns_zone_name      = "imranlearn.online"
dns_record_name    = "www.imranlearn.online"
cloudfront_aliases = [
  "www.imranlearn.online",
  "infra-imranlearn.online",
  "api.infra-imranlearn.online"
]

# ALB Ingress & ACM Certificate
enable_alb_ingress  = true
ingress_host        = "www.imranlearn.online"
acm_certificate_arn = "arn:aws:acm:us-east-1:147741822158:certificate/0a419ca2-cc77-4226-95b5-a01376f63313"
alb_name            = "cdec-alpha-alb"
