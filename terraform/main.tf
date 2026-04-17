terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {}

# Network
resource "docker_network" "monitoring" {
  name = "sre-monitoring-${var.environment}"
}

# Prometheus
resource "docker_container" "prometheus" {
  name  = "prometheus-${var.environment}"
  image = "prom/prometheus:${var.prometheus_version}"

  ports {
    internal = 9090
    external = var.prometheus_port
  }
}

# Grafana
resource "docker_container" "grafana" {
  name  = "grafana-${var.environment}"
  image = "grafana/grafana:${var.grafana_version}"

  ports {
    internal = 3000
    external = var.grafana_port
  }

  env = [
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}"
  ]
}

# Alertmanager
resource "docker_container" "alertmanager" {
  name  = "alertmanager-${var.environment}"
  image = "prom/alertmanager:${var.alertmanager_version}"

  ports {
    internal = 9093
    external = var.alertmanager_port
  }
}
