variable "vpc_id" {}

variable "vpc_private_subnets_cidr_blocks" {
  type = list(string)
}

variable "cluster_name" {}

variable "oidc_provider_arn" {}
