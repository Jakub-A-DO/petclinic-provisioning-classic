resource "google_compute_instance" "petclinic_nodes" {
  name                      = "${var.app_compute_node_name}-${count.index}"
  machine_type              = var.app_compute_node_machine_type
  allow_stopping_for_update = true
  count                     = var.app_compute_node_machine_count

  boot_disk {
    initialize_params {
      image = var.app_compute_node_image
    }
  }

  network_interface {
    network = var.network
    access_config {
    }
  }
  tags = var.app_compute_node_tags
}

resource "google_compute_instance" "petclinic_db_nodes" {
  name                      = "${var.db_compute_node_name}-${count.index}"
  machine_type              = var.db_compute_node_machine_type
  allow_stopping_for_update = true
  count                     = var.db_compute_node_machine_count

  boot_disk {
    initialize_params {
      image = var.db_compute_node_image
    }
  }

  network_interface {
    network = var.network
    access_config {
    }
  }
  service_account {
    email  = module.service_accounts_monitoring.email
    scopes = var.monitoring_service_account_scope
  }
  tags = var.monitoring_machine_tags
}

resource "google_compute_instance" "petclinic_monitoring_nodes" {
  name                      = "${var.monitoring_compute_node_name}-${count.index}"
  machine_type              = var.monitoring_compute_node_machine_type
  allow_stopping_for_update = true
  count                     = var.monitoring_compute_node_machine_count
  tags                      = var.monitoring_machine_tags

  boot_disk {
    initialize_params {
      image = var.monitoring_compute_node_image
    }
  }

  network_interface {
    network = var.network
    access_config {
    }
  }

  service_account {
    email  = module.service_accounts_monitoring.email
    scopes = var.monitoring_service_account_scope
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile(var.inventory_template_file_name, {
    instances = [
      for instance in google_compute_instance.petclinic_nodes : {
        name = instance.name
        ip   = instance.network_interface[0].access_config[0].nat_ip
      }
    ],
    db_instances = [
      for instance in google_compute_instance.petclinic_db_nodes : {
        name       = instance.name
        ip         = instance.network_interface[0].access_config[0].nat_ip
        private_ip = instance.network_interface[0].network_ip
      }
    ],

    db_master_instance = [
      {
        name       = google_compute_instance.petclinic_db_nodes[0].name
        private_ip = google_compute_instance.petclinic_db_nodes[0].network_interface[0].network_ip
      }
    ],
    db_standby_instance = [
      {
        name       = google_compute_instance.petclinic_db_nodes[1].name
        private_ip = google_compute_instance.petclinic_db_nodes[1].network_interface[0].network_ip
      }
    ],
    monitoring_master_instance = [
      {
        name       = google_compute_instance.petclinic_monitoring_nodes[0].name
        private_ip = google_compute_instance.petclinic_monitoring_nodes[0].network_interface[0].network_ip
      }
    ],
    monitoring_instances = [
      for instance in google_compute_instance.petclinic_monitoring_nodes : {
        name = instance.name
        ip   = instance.network_interface[0].access_config[0].nat_ip
      }
    ]
  })
  filename = var.inventory_file_name
}


resource "google_compute_firewall" "allow_grafana" {
  name    = "allow-grfana"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["3000", "9090"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["monitoring"]
}