provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central1"  # Modify this to your desired region
}

# Create the VPC network
resource "google_compute_network" "default" {
  name                    = "default-network"
  auto_create_subnetworks  = true
}

# Create a subnet for private instances
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"  # Modify this to match the region of your VPC
  network       = google_compute_network.default.self_link
}

# Create a subnet for public instances (to attach the Cloud NAT gateway)
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"  # Modify this to match the region of your VPC
  network       = google_compute_network.default.self_link
}

# Create a Cloud Router for NAT
resource "google_compute_router" "default" {
  name    = "cloud-router"
  region  = "us-central1"  # Same as the region of the NAT gateway and subnet
  network = google_compute_network.default.self_link
}

# Create Cloud NAT for the VPC network
resource "google_compute_router_nat" "default_nat" {
  name   = "default-nat"
  router = google_compute_router.default.name
  region = "us-central1"

  nat_ip_allocate_option = "AUTO_ONLY"  # Automatically allocate IP addresses
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"  # Apply NAT to all subnets

  # Configuring for all subnets (private or public)
  min_ports_per_vm = 64  # Minimum number of ports per VM
}

output "nat_ip_addresses" {
  value
