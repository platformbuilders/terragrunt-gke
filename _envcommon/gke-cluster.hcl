# Common configuration for the GKE module
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
  source = "${local.module_repo_url}//gke?ref=${local.module_version}"
}

# Common inputs for all environments
inputs = {
  # Default values used in all environments
  release_channel = "STABLE"
  
  # Private network settings
  is_public = false
  
  # Deletion protection settings
  deletion_protection = true
  
  # Common labels
  labels = {
    managed_by = "terragrunt"
    created_by = "devops-team"
  }
}
