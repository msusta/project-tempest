terraform {
  source = "https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-github-oidc-role?depth=1&ref=v5.54.1"
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

#generate "custom_policies" {
#  path      = "custom_policies.tf"
#  if_exists = "overwrite_terragrunt"
#  contents  = <<EOF
#resource "aws_iam_policy" "additional_policies" {
#  name_prefix = "github-infra-plan-additional"
#  path        = "/github/"
#  description = "Additional access for Github"
#  policy      = data.aws_iam_policy_document.additional_policies.json
#}
#
#data "aws_iam_policy_document" "additional_policies" {}
#
#resource "aws_iam_policy_attachment" "additional_policies" {
#  name       = "KMSUsage"
#  roles      = [aws_iam_role.this[0].name]
#  policy_arn = aws_iam_policy.additional_policies.arn
#}
#EOF
#}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = include.root.locals.merged["infra_ci_role"]
