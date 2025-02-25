provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central1"  # Change to your desired region
}

resource "google_compute_network" "default" {
  name                    = "default-network"
  auto_create_subnetworks  = true
}

resource "google_compute_subnetwork" "subnet" {
  name          = "default-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"  # Make sure this matches your region
  network       = google_compute_network.default.self_link
}

resource "google_compute_instance_group" "instance_group" {
  name        = "instance-group"
  zone        = "us-central1-a"  # Change to your preferred zone
  instances   = []  # You need to add instances to this group or use an Instance Template
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
  name          = "backend-service"
  protocol      = "HTTP"
  backends {
    group = google_compute_instance_group.instance_group.self_link
  }
  health_checks = [google_compute_health_check.http_health_check.id]
}

resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend_service.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name                  = "http-forwarding-rule"
  IP_address            = google_compute_global_address.lb_ip.address
  target                = google_compute_target_http_proxy.http_proxy.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_global_address" "lb_ip" {
  name          = "lb-ip-address"
  address_type  = "EXTERNAL"
}

output "load_balancer_ip" {
  value = google_compute_global_address.lb_ip.address
}
