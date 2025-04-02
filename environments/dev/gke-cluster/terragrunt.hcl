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
  cluster_name     = "gke-dev-cluster"
  master_location  = "us-central1"
  nodes_location   = ["us-central1-a", "us-central1-b", "us-central1-c"]
  min_master_version = "1.27"
  
  # CIDRs for the cluster
  master_cidr    = "172.16.0.0/28"
  pods_cidr      = "10.0.0.0/14"
  services_cidr  = "10.4.0.0/20"
  
  # Network configurations
  vpc_id     = "projects/your-dev-project/global/networks/vpc-dev"
  subnet_id  = "projects/your-dev-project/regions/us-central1/subnetworks/subnet-gke-dev"
  
  # Authorized IPs to access the master
  master_authorized_networks_config = [
    "10.0.0.0/8",
    "172.16.0.0/12"
  ]
  
  # Specific labels for the dev cluster
  labels = {
    environment = "development"
    purpose     = "development-workloads"
  }
}