provider "google" {
  project = "your-project-id"  # Replace with your GCP project ID
  region  = "us-central1"      # Replace with your desired region
}

# Define a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "gke-vpc-network"
  auto_create_subnetworks = false
}

# Define a subnet for the GKE cluster
resource "google_compute_subnetwork" "gke_subnetwork" {
  name          = "gke-subnetwork"
  region        = "us-central1"   # Replace with your desired region
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.0.0/16"   # Replace with your desired IP range
}

# Create the GKE cluster
resource "google_container_cluster" "gke_cluster" {
  name     = "example-gke-cluster"
  location = "us-central1-a"  # Replace with your desired zone (e.g., us-central1-b, us-central1-c, etc.)

  initial_node_count = 3  # Number of nodes in the cluster

  # Define node pool
  node_pool {
    name       = "default-node-pool"
    node_count = 3  # Replace with the desired number of nodes per pool
    node_config {
      machine_type = "e2-medium"  # Choose machine type (e.g., e2-medium, n1-standard-1)
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/userinfo.email"
      ]
    }

    management {
      auto_upgrade = true
      auto_repair  = true
    }
  }

  # Enable network policy for GKE
  network_policy {
    enabled = true
  }

  # Enable private cluster (optional)
  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false  # Set to true to allow private API access
  }

  # Set IP allocation
  ip_allocation_policy {
    use_ip_aliases = true
  }

  # Enable Cloud DNS for the cluster
  enable_dns = true
}

# Output the cluster name and endpoint
output "cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}
