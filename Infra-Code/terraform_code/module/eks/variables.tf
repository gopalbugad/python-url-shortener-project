variable "eks_cluster_name" {
  type = string
}

variable "eks_cluster_role" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "node_group_name" {
  type = string
}

variable "eks_node_role" {
  type = string
}

variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "rds-sg" {
  type = string
}