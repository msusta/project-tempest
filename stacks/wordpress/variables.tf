variable "name" {}

variable "vpc_id" {}

variable "database_subnet_group_name" {}

variable "vpc_private_subnets_cidr_blocks" {
  type = list(string)
}

variable "eks_cluster_name" {}

variable "domain" {}

variable "acm_certificate_arn" {}
