variable "name" {
    type = string
}

variable "local_version" {
    type = string
}

variable "env" {
    type = string
    default = "dev"
}

variable "subnet_ids" {
    type = list(string)
}


variable "node_label" {
    type = string
    default = "general"
}

variable "scaling_config" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })

  default = {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }
}

variable "instance_types" {
    type = list(string)
    default = ["t2.micro"]
}

variable "capacity_type" {
    type = string
    default = "ON_DEMAND"
}