variable "project" {
  type    = string
  default = "petclinic-444616"
}

variable "region" {
  type    = string
  default = "europe-central2"
}

variable "zone" {
  type    = string
  default = "europe-central2-c"
}

variable "network" {
  type    = string
  default = "default"
}

#### compute_instances.tf file ####

variable "app_compute_node_name" {
  type    = string
  default = "petclinic-dev-appnode"
}

variable "app_compute_node_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "app_compute_node_machine_count" {
  type    = number
  default = 0
}

variable "app_compute_node_image" {
  type    = string
  default = "debian-cloud/debian-11"
}


variable "app_compute_node_tags" {
  type    = list(string)
  default = ["http-server"]
}

variable "db_compute_node_name" {
  type    = string
  default = "petclinic-dev-dbnode"
}

variable "db_compute_node_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "db_compute_node_machine_count" {
  type    = number
  default = 2
}

variable "db_compute_node_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "db_compute_node_network" {
  type    = string
  default = "default"
}

variable "monitoring_compute_node_name" {
  type    = string
  default = "petclinic-dev-monitoring-node"
}

variable "monitoring_compute_node_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "monitoring_compute_node_machine_count" {
  type    = number
  default = 1
}

variable "monitoring_compute_node_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "monitoring_compute_node_network" {
  type    = string
  default = "default"
}

variable "inventory_template_file_name" {
  type    = string
  default = "./inventory-dev.tmpl"
}

variable "inventory_file_name" {
  type    = string
  default = "inventory-dev.ini"
}

variable "monitoring_machine_tags" {
  type    = list(string)
  default = ["allow-health-check", "monitoring"]
}

#####################################

############ main.tf file #############

variable "artifact_registry_format" {
  type    = string
  default = "docker"
}

variable "artifact_registry_id" {
  type    = string
  default = "docker-image-registry"
}

variable "service_accounts_workload_prefix" {
  type    = string
  default = "github-actions"
}

variable "service_accounts_workload_names" {
  type    = list(string)
  default = ["petclinic"]
}

variable "service_accounts_workload_project_roles" {
  type = list(string)
  default = [
    "petclinic-444616=>roles/artifactregistry.createOnPushWriter", "petclinic-444616=>roles/iam.workloadIdentityUser", "petclinic-444616=>roles/compute.instanceAdmin.v1"
  ]
}

variable "service_accounts_workload_names_terraform" {
  type    = list(string)
  default = ["petclinic-tf"]
}

variable "service_accounts_workload_project_roles_terraform" {
  type = list(string)
  default = [
    "petclinic-444616=>roles/iam.workloadIdentityUser", "petclinic-444616=>roles/editor", "petclinic-444616=>roles/storage.objectAdmin"
  ]
}

variable "service_accounts_instance_names" {
  type    = list(string)
  default = ["instance-sa"]
}

variable "service_accounts_instance_project_roles" {
  type = list(string)
  default = [
    "petclinic-444616=>roles/artifactregistry.createOnPushWriter", "petclinic-444616=>roles/artifactregistry.reader", "petclinic-444616=>roles/browser"
  ]
}

variable "service_accounts_monitoring_names" {
  type    = list(string)
  default = ["petclinic-monitoring"]
}

variable "service_accounts_monitoring_project_roles" {
  type = list(string)
  default = [
    "petclinic-444616=>roles/compute.viewer", "petclinic-444616=>roles/monitoring.viewer"
  ]
}


variable "monitoring_service_account_scope" {
  type = list(string)
  default = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/logging.read",
    "https://www.googleapis.com/auth/compute.readonly",
    "https://www.googleapis.com/auth/monitoring.read"
  ]
}

#############################################

############ instance_group_with_lb.tf ###########

variable "autoscaler_min_replicas" {
  type    = number
  default = 3
}

variable "autoscaler_max_replicas" {
  type    = number
  default = 3
}

variable "autoscaler_cooldown_period" {
  type    = number
  default = 60
}

variable "autoscaler_cpu_utilization" {
  type    = number
  default = 0.6
}

variable "instance_template_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "instance_template_machine_tags" {
  type    = list(string)
  default = ["allow-health-check", "http-server"]
}

variable "instance_template_image" {
  type    = string
  default = "debian-cloud/debian-11"
}

variable "instance_template_disk_size" {
  type    = number
  default = 10
}

variable "instance_template_service_account_scope" {
  type = list(string)
  default = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/devstorage.read_only"
  ]
}

variable "instance_group_manager_base_instance_name" {
  type    = string
  default = "petclinic-app"
}

variable "instance_group_manager_named_port_name" {
  type    = string
  default = "http"
}

variable "instance_group_manager_named_port_number" {
  type    = number
  default = 80
}

variable "startup_script_path" {
  type    = string
  default = "./startup-script.sh"
}