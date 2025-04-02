# Common configuration for the NodePool module
locals {
  # Load environment variables
  env_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  
  # Module repository URL
  module_repo_url = local.env_vars.locals.module_repo_url
  module_version = local.env_vars.locals.module_version
}

# Module reference
terraform {
  # Using a module from a git repository
  source = "${local.module_repo_url}//nodepool?ref=${local.module_version}"
}

# Common inputs for all environments
inputs = {
  # Default disk configuration
  disk_size_gb = 100
  
  # Default values for machine type (can be overridden per environment)
  machine_type = "e2-standard-2"
}
