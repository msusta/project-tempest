# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"

  config = {
    # single Tfstate bucket per AWS account
    bucket = "${get_aws_account_id()}-tf-state"
    # key reflects path to module for deconfliction
    key    = "${replace(path_relative_to_include(), "/^[^/]+//", "")}/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table                 = "${get_aws_account_id()}-tf-state"
    # encryption not needed, no interesting information
    enable_lock_table_ssencryption = false

    # bucket encryption by default
    encrypt              = true
    bucket_sse_algorithm = "AES256"

    # ensure all security is enabled
    skip_bucket_versioning             = false
    skip_bucket_ssencryption           = false
    skip_bucket_enforced_tls           = false
    skip_bucket_public_access_blocking = false
  }

  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))
}

locals {
  # no secrets to manage atm
  #secret_vars  = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))

  # loaded always
  global_vars  = yamldecode(file("${find_in_parent_folders("global.yaml")}"))
  #account_vars = yamldecode(file("${find_in_parent_folders("account.yaml")}"))
  env_vars     = yamldecode(file("${find_in_parent_folders("env.yaml")}"))

  # only if include is from env
  #env_vars = length(split("/", path_relative_to_include())) >= 3 ? yamldecode(file("${find_in_parent_folders("env.yaml")}")) : tomap({})

  # calculate some local variables to remove the need to use the complex "envs" map directly in terraform inputs
  #environment           = local.env_vars["environment"]
  #account_id            = local.account_vars["aws_account_id"]
  state_variables = {
    state_s3_bucket      = "${get_aws_account_id()}-tf-state"
    state_dynamodb_table = "${get_aws_account_id()}-tf-state"
  }

  merged = merge(
    #local.secret_vars,
    local.global_vars,
    #local.account_vars,
    local.env_vars,
    local.state_variables
  )
}

# This forces use of global shared namespace
# for all variables, which limits ability to
# use same stacks repeatedly
#inputs = merge(
#  #local.secret_vars,
#  local.global_vars,
#  local.account_vars,
#  local.env_vars,
#  local.state_variables
#)
