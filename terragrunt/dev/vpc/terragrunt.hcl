terraform {
  source = "https://github.com/terraform-aws-modules/terraform-aws-vpc.git?depth=1&ref=v5.19.0"
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

inputs = include.root.locals.merged["vpc"]
