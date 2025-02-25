provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central1"   # Change to your desired region
  zone    = "us-central1-a" # Change to your desired zone
}

resource "google_compute_network" "default" {
  name                    = "default-network"
  auto_create_subnetworks = true
}

resource "google_compute_subnetwork" "subnet" {
  name          = "internal-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"  # Make sure this matches your region
  network       = google_compute_network.default.self_link
}

resource "google_compute_instance_group" "instance_group" {
  name        = "instance-group"
  zone        = "us-central1-a"  # Change to your preferred zone
  instances   = []
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "http_health_check" {
  name               = "http-health-check"
  http_health_check {
    port               = 80
    request_path       = "/"
  }
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2
}

resource "google_compute_backend_service" "backend_service" {
  name          = "internal-backend-service"
  protocol      = "HTTP"
  backends {
    group = google_compute_instance_group.instance_group.self_link
  }

  health_checks = [google_compute_health_check.http_health_check.id]
  load_balancing_scheme = "INTERNAL"
  region = "us-central1"  # Ensure this matches your region
}

resource "google_compute_forwarding_rule" "internal_lb" {
  name                  = "internal-load-balancer"
  region                = "us-central1"  # Ensure this matches your region
  IP_address            = google_compute_address.internal_ip.address
  target                = google_compute_backend_service.backend_service.id
  port_range            = "80"
  load_balancing_scheme = "INTERNAL"
  network               = google_compute_network.default.self_link
  subnetwork            = google_compute_subnetwork.subnet.self_link
}

resource "google_compute_address" "internal_ip" {
  name          = "internal-ip-address"
  region        = "us-central1"  # Ensure this matches your region
  subnetwork    = google_compute_subnetwork.subnet.self_link
  address_type  = "INTERNAL"
}

output "load_balancer_ip" {
  value = google_compute_address.internal_ip.address
}
