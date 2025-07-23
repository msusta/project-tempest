terraform {
  source = "https://github.com/terraform-aws-modules/terraform-aws-rds.git//modules/db_subnet_group?depth=1&ref=v6.12.0"
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
  include.root.locals.merged["rds_subnet_group"],
  {
    subnet_ids = dependency.vpc.outputs.database_subnets
  }
)
