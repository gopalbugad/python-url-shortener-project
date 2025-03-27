variable "allocated_storage" {
  type = number
}

variable "instance_class" {
  type = string
}

variable "publicly_accessible" {
  type = bool
}

variable "deletion_protection" {
  type = bool
}

variable "identifier" {
  type = string
}

variable "backup_retention_period" {
  type = number
}

variable "engine_version" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "eks-sg-id" {
  type = string
}