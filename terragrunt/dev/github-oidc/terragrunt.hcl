terraform {
  source = "https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-github-oidc-provider?depth=1&ref=v5.54.1"
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
