# Includes the environment configuration
include {
  path = find_in_parent_folders()
}

# Includes the common component configuration
include "common" {
  path = "${get_terragrunt_dir()}/../../../_envcommon/gke-cluster.hcl"
}

# Specific inputs for this cluster
inputs = {
  cluster_name     = "gke-prod-cluster"
  master_location  = "us-central1"
  nodes_location   = ["us-central1-a", "us-central1-b", "us-central1-c"]
  min_master_version = "1.27"
  
  # CIDRs for the cluster
  master_cidr    = "172.16.0.32/28"
  pods_cidr      = "10.8.0.0/14"
  services_cidr  = "10.12.0.0/20"
  
  # Network configurations
  vpc_id     = "projects/your-prod-project/global/networks/vpc-prod"
  subnet_id  = "projects/your-prod-project/regions/us-central1/subnetworks/subnet-gke-prod"
  
  # Authorized IPs to access the master (more restricted in production)
  master_authorized_networks_config = [
    "10.0.0.0/8"
  ]
  
  # Specific configurations for the production environment
  release_channel = "REGULAR"
  
  # Specific labels for the prod cluster
  labels = {
    environment = "production"
    purpose     = "production-workloads"
  }
}
