##########################################################
# EKS VPC
##########################################################
module "vpc" {
  source = "../../modules/vpc"

  name             = "myvpc"
  region           = var.region
  azs              = ["us-east-1a", "us-east-1b"]
  cidr_block       = var.cidr_block
  eks_cluster_name = var.eks_cluster_name
}



##########################################################
# EKS CLUSTER
##########################################################
module "eks_cluster" {
  source = "../../modules/eks_cluster"

  name          = var.eks_cluster_name
  local_version = var.eks_cluster_version
  subnet_ids    = module.vpc.private_subnet_ids

  instance_types = ["t3.small"]

  scaling_config = {
    desired_size = 1
    max_size     = 10
    min_size     = 1
  }
}



##########################################################
# IAM USERS
##########################################################
module "iam" {
  source = "../../modules/IAM"

  env = var.env
  eks_cluster_name = var.eks_cluster_name
}


##########################################################
# POD IDENTITY
##########################################################
module "addons" {
  source = "../../modules/aws_addons"

  env = var.env
  eks_cluster_name = var.eks_cluster_name
  addon_names = {
    "eks-pod-identity-agent" = "v1.3.7-eksbuild.2"
    "aws-ebs-csi-driver" = "v1.44.0-eksbuild.1"
  }
}


##########################################################
# HELM
##########################################################
module "helm" {
  source = "../../modules/helm"
  eks_nodes_group = module.eks_cluster.eks_nodes_group
  eks_cluster_name = var.eks_cluster_name
  region = var.region
  vpc_id = module.vpc.vpc_id
}

##########################################################
# AWS LBC
##########################################################
module "aws_lbc" {
  source = "../../modules/aws_lbc"
  env = var.env
  eks_cluster_name = var.eks_cluster_name
}


##########################################################
# POSTGRES
##########################################################
module "postgres" {
  source = "../../modules/postgres"
  env = var.env
  vpc_id = module.vpc.vpc_id
  postgres_db_name = "auth-db"
  postgres_instance_username = var.postgres_username
  postgres_instance_password = var.postgres_password
}