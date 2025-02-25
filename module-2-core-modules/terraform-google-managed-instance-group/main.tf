provider "google" {
  project = "your-project-id"
  region  = "us-central1"  # Replace with your desired region
}

# Define the instance template to use in the managed instance group
resource "google_compute_instance_template" "example" {
  name         = "example-instance-template"
  machine_type = "e2-medium"
  region       = "us-central1" # Replace with your region
  tags         = ["http-server", "https-server"]

  # Define the boot disk
  disk {
    auto_delete = true
    boot        = true
    initialize_params {
      image = "debian-11-bullseye-v20230214"
    }
  }

  # Define the network interface
  network_interface {
    network = "default"
    access_config {
      # Ephemeral external IP
    }
  }

  # Metadata for the instance
  metadata = {
    ssh-keys = "your-username:ssh-rsa your-ssh-public-key"
  }

  # Cloud-init user data script (optional)
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
  EOT
}

# Create a Managed Instance Group
resource "google_compute_instance_group_manager" "example" {
  name               = "example-mig"
  zone               = "us-central1-a"  # Replace with your desired zone
  version {
    instance_template = google_compute_instance_template.example.self_link
  }

  target_size = 3  # The number of instances in the MIG

  # Autoscaler configuration (optional)
  autoscaler {
    target_cpu_utilization {
      target = 0.6
    }

    min_num_replicas = 1
    max_num_replicas = 5
  }

  # Health check configuration
  health_check {
    check_interval_sec = 5
    timeout_sec        = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
    http_health_check {
      port = 80
      request_path = "/"
    }
  }
}

# Output the name of the instance group manager
output "instance_group_manager_name" {
  value = google_compute_instance_group_manager.example.name
}
