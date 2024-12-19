resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_region_autoscaler" "petclinic" {
  name   = "my-region-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.petclinic.id

  autoscaling_policy {
    min_replicas    = var.autoscaler_min_replicas
    max_replicas    = var.autoscaler_max_replicas
    cooldown_period = var.autoscaler_cooldown_period

    cpu_utilization {
      target = var.autoscaler_cpu_utilization
    }
  }
}

# create an instance template

resource "google_compute_instance_template" "petclinic" {
  name_prefix  = "test-app-lb-group1-mig"
  machine_type = var.instance_template_machine_type
  tags         = var.instance_template_machine_tags

  disk {
    source_image = var.instance_template_image
    disk_size_gb = var.instance_template_disk_size
  }

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    network = var.network

    # secret default
    access_config {
    }
  }

  service_account {
    email  = module.service_accounts_instance.email
    scopes = var.instance_template_service_account_scope
  }

  metadata = {
    startup-script            = local.startup_script_content # this is where startup script file is passed.
    promtail_config           = local.promtail_config
    app_docker_compose        = local.app_docker_compose_content
    monitoring_docker_compose = local.monitoring_docker_compose_content
  }
}

# create a target pool for instance group
# resource "google_compute_target_pool" "petclinic" {
#   name = "my-target-pool"
# }

# create an instance group manager

resource "google_compute_region_instance_group_manager" "petclinic" {
  name   = "test-app-lb-group1-mig"
  region = var.region

  version {
    instance_template = google_compute_instance_template.petclinic.id
    name              = "primary"
  }

  named_port {
    name = var.instance_group_manager_named_port_name
    port = var.instance_group_manager_named_port_number
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 120
  }

  base_instance_name = var.instance_group_manager_base_instance_name
}

# create locals block to hold the startup script. This is passed in instance template block.
locals {
  startup_script_path = var.startup_script_path
  startup_script_content = templatefile(local.startup_script_path, {
    db_ip = google_compute_instance.petclinic_db_nodes[0].network_interface[0].network_ip
  })
}

locals {
  promtail_config_path = "./promtail_config.yaml"
  promtail_config = templatefile(local.promtail_config_path, {
    monitoring_private_ip = google_compute_instance.petclinic_monitoring_nodes[0].network_interface[0].network_ip
  })
}

locals {
  monitoring_docker_compose_file_path = "./docker-compose-monitoring.yml"
  monitoring_docker_compose_content   = file(local.monitoring_docker_compose_file_path)
}

locals {
  app_docker_compose_file_path = "./docker-compose-app.yml"
  app_docker_compose_content   = file(local.app_docker_compose_file_path)
}

resource "google_compute_backend_service" "default" {
  name                  = "test-app-lb-backend-default"
  provider              = google-beta
  project               = var.project
  protocol              = "HTTP"
  session_affinity      = "NONE"
  port_name             = var.instance_group_manager_named_port_name
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  enable_cdn            = false
  health_checks         = [google_compute_health_check.default.id]
  backend {
    group           = google_compute_region_instance_group_manager.petclinic.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_health_check" "default" {
  name               = "http-health-check"
  timeout_sec        = 120
  check_interval_sec = 120

  http_health_check {
    port         = var.instance_group_manager_named_port_number
    request_path = "/"
  }
}

# 1. Global IP address for the load balancer
resource "google_compute_global_address" "lb_ip" {
  name = "petclinic-lb-ip"
}

# 2. URL map to route requests to your backend
resource "google_compute_url_map" "url_map" {
  name            = "petclinic-url-map"
  default_service = google_compute_backend_service.default.id
}

# 3. HTTP proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "petclinic-http-proxy"
  url_map = google_compute_url_map.url_map.id
}

# 4. Forwarding rule
resource "google_compute_global_forwarding_rule" "http" {
  name       = "petclinic-http-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = var.instance_group_manager_named_port_number
  ip_address = google_compute_global_address.lb_ip.address
}