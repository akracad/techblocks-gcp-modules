provider "google" {
  project = "your-project-id"
  region  = "us-central1"  # Replace with your desired region
}

# Create a Cloud SQL instance
resource "google_sql_database_instance" "example" {
  name             = "example-sql-instance"
  region           = "us-central1"  # Replace with your desired region
  database_version = "MYSQL_8_0"  # You can choose between MYSQL, POSTGRES, or SQLSERVER

  settings {
    tier = "db-f1-micro"  # The machine type for your SQL instance (e.g., db-f1-micro, db-n1-standard-1)
    
    # Configuration for storage and backups
    backup_configuration {
      enabled = true
      start_time = "03:00"  # Time for daily backups (in UTC)
    }

    ip_configuration {
      authorized_networks {
        name  = "my-network"
        value = "0.0.0.0/0"  # Allow all IPs (replace with a more restricted IP range for production)
      }
      ipv4_enabled = true  # Enable IPv4
    }

    data_disk_size_gb = 10  # Size of the storage disk for the instance (in GB)
    data_disk_type    = "PD_SSD"  # You can also use "PD_HDD"
  }
}

# Create a database within the SQL instance
resource "google_sql_database" "example_db" {
  name     = "example-database"
  instance = google_sql_database_instance.example.name

  charset = "utf8mb4"  # Optional: Set the character set for the database
  collation = "utf8mb4_general_ci"  # Optional: Set the collation for the database
}

# Create a database user for the SQL instance
resource "google_sql_user" "example_user" {
  name     = "example-user"
  instance = google_sql_database_instance.example.name
  password = "your-password"  # Replace with a secure password

  host = "%"  # Set to "%" to allow access from any IP address, or provide a specific IP range
}

# Output the instance name and connection details
output "sql_instance_name" {
  value = google_sql_database_instance.example.name
}

output "sql_instance_connection_name" {
  value = google_sql_database_instance.example.connection_name
}
