variable "eks_cluster_name" {
  type = string
}

variable "eks_cluster_version" {
  type    = string
  default = "1.33"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "postgres_username" {
  type        = string
  description = "PostgreSQL database username"
  sensitive   = true
}

variable "postgres_password" {
  type        = string
  description = "PostgreSQL database password"
  sensitive   = true
}