terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=6.8.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}


resource "random_id" "default" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name     = "${random_id.default.hex}-terraform-remote-backend"
  location = "US"

  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "local_file" "default" {
  file_permission = "0644"
  filename        = "${path.module}/backend.tf"

  # You can store the template in a file and use the templatefile function for
  # more modularity, if you prefer, instead of storing the template inline as
  # we do here.
  content = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.default.name}"
    }
  }
  EOT
}

# resource "google_iam_workload_identity_pool" "github" {
#   disabled                  = false
#   workload_identity_pool_id = "github-actions"
#   display_name              = "Github actions"
#   description               = "Identity pool for github-actions"
#   project                   = "334892833978"
# }

# resource "google_iam_workload_identity_pool_provider" "github_provider" {
#   provider = google

#   workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
#   workload_identity_pool_provider_id = "github-provider"
#   display_name                       = "GitHub Actions Provider"
#   attribute_condition                = <<EOT
#     assertion.repository_owner_id == "32469368" &&
#     attribute.repository == "Lastferbbs/spring-petclinic" &&
#     assertion.ref == "refs/heads/main" &&
#     assertion.ref_type == "branch"
# EOT

#   attribute_mapping = {
#     "google.subject"       = "assertion.sub"
#     "attribute.actor"      = "assertion.actor"
#     "attribute.aud"        = "assertion.aud"
#     "attribute.repository" = "assertion.repository"
#   }

#   oidc {
#     issuer_uri = "https://token.actions.githubusercontent.com"
#   }
# }

# resource "google_service_account_iam_member" "workload_identity_user" {
#   service_account_id = "projects/petclinic-444616/serviceAccounts/${module.service_accounts.email}"
#   role               = "roles/iam.workloadIdentityUser"
#   member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/Lastferbbs/spring-petclinic"
# }