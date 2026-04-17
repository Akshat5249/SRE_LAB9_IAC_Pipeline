variable "prometheus_version" {
  default = "latest"
}

variable "grafana_version" {
  default = "latest"
}

variable "alertmanager_version" {
  default = "latest"
}

variable "grafana_admin_password" {
  type = string
}

variable "environment" {
  default = "dev"
}

variable "prometheus_port" { default = 9090 }
variable "grafana_port" { default = 3000 }
variable "alertmanager_port" { default = 9093 }