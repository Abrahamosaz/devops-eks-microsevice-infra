variable "postgres_db_name" {
  type        = string
  description = "The name of the RDS instance"
}

variable "postgres_instance_username" {
  type        = string
  description = "The username of the RDS instance"
}

variable "postgres_instance_password" {
  type        = string
  description = "The password of the RDS instance"
}


variable "rds_allocated_storage" {
  type        = number
  default     = 10
  description = "The allocated storage of the RDS instance"
}


variable "postgres_instance_engine_version" {
  type        = string
  default     = "16.3"
  description = "The engine version of the RDS instance"
}

variable "postgres_instance_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "The instance class of the RDS instance"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}


variable "env" {
  type        = string
  description = "dev"
}
