# Includes the environment configuration
include {
  path = find_in_parent_folders()
}

# Includes the common component configuration
include "common" {
  path = "${get_terragrunt_dir()}/../../../_envcommon/gke-nodepool.hcl"
}

# Defines the cluster dependency
dependency "gke" {
  config_path = "../gke-cluster"
  
  # Defines the cluster outputs you need
  mock_outputs = {
    name = "mock-cluster"
    master_location = "us-central1"
  }
}

# Specific inputs for this node pool
inputs = {
  node_pool_name = "prod-default-pool"
  
  # Uses the cluster name from the dependency
  cluster_name   = dependency.gke.outputs.name
  master_location = dependency.gke.outputs.master_location
  
  # Specific configurations for the production environment
  machine_type = "e2-standard-4"
  disk_size_gb = 200
  
  # Scalability configurations for production
  initial_node_count = 3
  min_node_count     = 3
  max_node_count     = 10
}
