terraform {
  source = "../../../stacks/eks-svc"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"
}
dependency "eks" {
  config_path = "../eks"
}

inputs = merge(#include.root.locals.merged["eks_alb"],
  {
    vpc_id = dependency.vpc.outputs.vpc_id

    cluster_name      = dependency.eks.outputs.cluster_name
    oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn
  }
)
