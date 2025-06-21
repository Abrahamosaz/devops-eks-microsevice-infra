variable "env" {
    type = string
}

variable "eks_cluster_name" {
    type = string
}

variable "addon_names" {
    type = map(string)
}