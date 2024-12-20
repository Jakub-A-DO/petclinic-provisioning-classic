module "artifact_registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.3"

  # Required variables
  project_id    = var.project
  location      = var.region
  format        = var.artifact_registry_format
  repository_id = var.artifact_registry_id
}

module "service_accounts_workload" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.0"
  project_id    = var.project
  prefix        = var.service_accounts_workload_prefix
  names         = var.service_accounts_workload_names
  project_roles = var.service_accounts_workload_project_roles
}

module "service_accounts_workload_terraform" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.0"
  project_id    = var.project
  prefix        = var.service_accounts_workload_prefix
  names         = var.service_accounts_workload_names_terraform
  project_roles = var.service_accounts_workload_project_roles_terraform
}

module "service_accounts_monitoring" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.0"
  project_id    = var.project
  names         = var.service_accounts_monitoring_names
  project_roles = var.service_accounts_monitoring_project_roles
}

module "service_accounts_instance" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.0"
  project_id    = var.project
  names         = var.service_accounts_instance_names
  project_roles = var.service_accounts_instance_project_roles
}


# backend service with custom request and response headers








