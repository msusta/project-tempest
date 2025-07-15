terraform {
  source = "../../../stacks/wordpress"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"
}
dependency "rds_subnet_group" {
  config_path = "../rds-subnet-group"
}
dependency "eks" {
  config_path = "../eks"
}

inputs = merge(include.root.locals.merged["wordpress_blog"],
  {
    vpc_id                          = dependency.vpc.outputs.vpc_id
    database_subnet_group_name      = dependency.rds_subnet_group.outputs.db_subnet_group_id
    vpc_private_subnets_cidr_blocks = dependency.vpc.outputs.private_subnets_cidr_blocks

    eks_cluster_name = dependency.eks.outputs.cluster_name
  }
)
