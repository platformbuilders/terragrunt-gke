# Global Terragrunt configuration
locals {
  # Automatically loads environment variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))

  # Gets the environment name from the path
  environment = basename(get_terragrunt_dir())
  
  # Your module repository URL
  # Option 1: Via HTTPS
  module_repo_url = "https://github.com/your-company/terraform-modules-gcp.git"
  # Option 2: If it's a private repository, consider using SSH
  # module_repo_url = "git@github.com:your-company/terraform-modules-gcp.git"
  
  # Version (tag) of the modules to be used
  # Use a specific commit, branch, or tag
  module_version = "v1.0.0"
}

# Remote state configuration in GCS
remote_state {
  backend = "gcs"
  config = {
    project  = "your-gcp-project"
    location = "us-central1"
    bucket   = "your-project-tfstate"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Global provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  project = "your-gcp-project"
  region  = "us-central1"
}
EOF
}

# Global input configuration (common variables for all environments)
inputs = {
  project_id = "your-gcp-project"
}
