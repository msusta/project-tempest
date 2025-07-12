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
