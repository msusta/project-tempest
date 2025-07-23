terraform {
  source = "https://github.com/terraform-aws-modules/terraform-aws-eks.git?depth=1&ref=v20.37.1"
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {}
}
EOF
}

#generate "efs" {
#  path      = "efs.tf"
#  if_exists = "overwrite_terragrunt"
#  contents  = <<EOF
## IAM
#module "role_efs_csi" {
#  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#  version = "~> 5.59.0"
#
#  role_name_prefix = "${var.cluster_name}-efs-csi"
#
#  oidc_providers = {
#    eks = {
#      provider_arn               = aws_iam_openid_connect_provider.oidc_provider[0].arn
#      namespace_service_accounts = ["kube-system:efs-csi"]
#    }
#  }
#
#  attach_efs_csi_policy = true
#}
#
## SA
#resource "kubernetes_service_account" "efs_csi" {
#  metadata {
#    name = "efs-csi"
#    namespace = "kube-system"
#    labels = {
#        "app.kubernetes.io/name"= "efs-csi"
#    }
#    annotations = {
#      "eks.amazonaws.com/role-arn" = module.role_efs_csi.iam_role_arn
#      "eks.amazonaws.com/sts-regional-endpoints" = "true"
#    }
#  }
#}
#EOF
#}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = merge(
  include.root.locals.merged["eks"],
  {
    vpc_id     = dependency.vpc.outputs.vpc_id
    subnet_ids = dependency.vpc.outputs.private_subnets

  }
)
