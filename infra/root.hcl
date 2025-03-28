locals {
  github_token = get_env("GITHUB_TOKEN", "not_set")

  git_remote     = run_cmd("--terragrunt-quiet", "git", "remote", "get-url", "origin")
  github_repo    = regex("[/:]([-0-9_A-Za-z]*/[-0-9_A-Za-z]*)[^/]*$", local.git_remote)[0]
  repo_owner     = split("/", local.github_repo)[0]
  aws_account_id = get_aws_account_id()

  path_parts  = split("/", get_terragrunt_dir())
  module      = local.path_parts[length(local.path_parts) - 1]
  provider    = local.path_parts[length(local.path_parts) - 2]
  environment = local.path_parts[length(local.path_parts) - 3]

  global_vars      = read_terragrunt_config(find_in_parent_folders("global_vars.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment_vars.hcl"))

  aws_region       = local.global_vars.inputs.aws_region
  project_name     = replace(local.github_repo, "/", "-")
  deploy_role_name = "${local.project_name}-${local.environment}-github-oidc-role"
  state_bucket     = "${local.aws_account_id}-${local.aws_region}-${local.project_name}-tfstate"
  state_key        = "${local.environment}/${local.provider}/${local.module}/terraform.tfstate"
  state_lock_table = "${local.project_name}-tf-lockid"
}

terraform {
  before_hook "print_locals" {
    commands = ["init"]
    execute = [
      "bash", "-c", "echo STATE:${local.state_bucket}/${local.state_key} TABLE:${local.state_lock_table}"
    ]
  }
}

remote_state {
  backend = "s3"
  config = {
    bucket         = local.state_bucket
    key            = local.state_key
    region         = local.aws_region
    dynamodb_table = local.state_lock_table
    encrypt        = true
  }
}

generate "versions" {
  # this allows individual provider versioning for local modules
  path      = "versions.tf"
  if_exists = "skip"
  contents  = ""
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "skip"
  contents  = <<EOF
terraform {
  backend "s3" {}
}
EOF
}

generate "aws_provider" {
  path      = "provider_aws.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region              = "${local.aws_region}"
  allowed_account_ids = ["${local.aws_account_id}"]
}
provider "aws" {
  alias = "domain_aws_region"
  allowed_account_ids = ["${local.aws_account_id}"]
  # needs to be us-east-1
  region = "us-east-1"
}
EOF
  disable   = local.provider != "aws"
}

generate "github_provider" {
  path      = "provider_github.tf"
  if_exists = "overwrite" # Ensures GitHub token is refreshed
  contents  = <<EOF
provider "github" {
  token = "${local.github_token}"
  owner = "${local.repo_owner}"
}
EOF
  disable   = local.provider != "github"
}

inputs = merge(
  local.global_vars.inputs,
  local.environment_vars.inputs,
  {
    aws_account_id      = local.aws_account_id
    aws_region          = local.aws_region
    project_name        = local.project_name
    environment         = local.environment
    deploy_environments = [local.environment]
    github_repo         = local.github_repo
    deploy_role_name    = local.deploy_role_name
    state_bucket        = local.state_bucket
    state_lock_table    = local.state_lock_table
  }
)
