provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central1"
}

resource "google_workspace_admin_sdk" "vault" {
  account_id = "your-admin-account-id"
  email      = "admin@example.com"
}

resource "google_vault_retention_rule" "retention_rule" {
  name          = "Retention Rule for Gmail"
  description   = "This retention rule is applied to Gmail"
  query         = "accounts:example.com AND is:sent"
  match_attachments = true
  retention_duration = "365d"  # Retain messages for 1 year
  
  # You can specify Gmail, Drive, or other data types for retention rules.
  data_scope = "GMAIL"
}

resource "google_vault_hold" "hold" {
  name        = "Important Hold"
  description = "Hold for critical records"
  query       = "account:example.com"
  
  # You can specify the hold type and more.
  hold_type = "LEGAL"
}

output "vault_hold_id" {
  value = google_vault_hold.hold.id
}

output "vault_retention_rule_id" {
  value = google_vault_retention_rule.retention_rule.id
}
