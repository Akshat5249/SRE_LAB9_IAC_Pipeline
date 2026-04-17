# SRE Lab 9

Infrastructure-as-Code lab for standing up a local monitoring stack with Terraform and configuring it with Ansible. The project provisions Prometheus, Grafana, and Alertmanager as Docker containers, then applies monitoring configuration such as Prometheus alert rules and Grafana datasource settings.

## What This Project Does

- Uses Terraform to create:
  - A Docker network for the monitoring stack
  - A Prometheus container
  - A Grafana container
  - An Alertmanager container
- Uses Ansible to configure:
  - Prometheus alert rules
  - Grafana datasource provisioning
  - A basic Alertmanager receiver configuration
- Uses GitHub Actions to validate:
  - `terraform init`
  - `terraform validate`
  - `terraform fmt -check`
  - `ansible-playbook site.yml --syntax-check`

## Project Structure

```text
sre-lab9/
├── .github/workflows/iac_validate.yml
├── ansible/
│   ├── inventory.ini
│   ├── site.yml
│   ├── vars/secrets.yml
│   └── roles/
│       ├── prometheus_rules/
│       ├── grafana_dashboards/
│       └── alertmanager_config/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
└── README.md
```

## Architecture

Terraform provisions the monitoring containers locally through the Docker provider. Ansible then targets `localhost` and uses `docker cp` plus container restarts to inject configuration into the running services.

Default service ports:

- Prometheus: `9090`
- Grafana: `3000`
- Alertmanager: `9093`

Default container naming pattern:

- `prometheus-<environment>`
- `grafana-<environment>`
- `alertmanager-<environment>`

With the default `environment = "dev"`, the container names become:

- `prometheus-dev`
- `grafana-dev`
- `alertmanager-dev`

## Prerequisites

Make sure these are installed on your machine:

- Docker
- Terraform
- Ansible

You also need Docker running locally before applying Terraform.

## Terraform Workflow

From the `terraform/` directory:

```bash
terraform init
terraform plan
terraform apply
```

The main variables currently used are:

- `grafana_admin_password`
- `environment`
- `prometheus_port`
- `grafana_port`
- `alertmanager_port`
- `prometheus_version`
- `grafana_version`
- `alertmanager_version`

Example `terraform.tfvars`:

```hcl
grafana_admin_password = "change-me"
environment = "dev"
```

After a successful apply, Terraform outputs the container names for Prometheus, Grafana, and Alertmanager.

## Ansible Workflow

From the `ansible/` directory:

```bash
ansible-playbook -i inventory.ini site.yml
```

What the playbook does:

- Copies `sre_alerts.yml` into the Prometheus container
- Copies `datasource.yml` into the Grafana provisioning path
- Restarts Grafana to load the datasource
- Creates a minimal Alertmanager configuration file

You can also run tagged portions:

```bash
ansible-playbook -i inventory.ini site.yml --tags prometheus
ansible-playbook -i inventory.ini site.yml --tags grafana
ansible-playbook -i inventory.ini site.yml --tags alertmanager
```

## Monitoring Configuration

### Prometheus

Prometheus is configured with:

- `15s` scrape interval
- `15s` evaluation interval
- Local alert rules loaded from `sre_alerts.yml`

The current sample alert rule is:

- `HighCPUUsage`

It fires when CPU usage is above `80%` for `1m`.

### Grafana

Grafana is provisioned with a Prometheus datasource pointing to:

```text
http://host.docker.internal:9090
```

Default username:

```text
admin
```

The admin password is injected from Terraform via `GF_SECURITY_ADMIN_PASSWORD`.

### Alertmanager

The current role generates a minimal configuration with a single default receiver. This is a good starting point, but in a production-ready version you would usually extend it with email, Slack, PagerDuty, or webhook receivers.

## CI Validation

GitHub Actions runs an IaC validation pipeline on pushes to `main` and on pull requests. The workflow checks:

- Terraform initialization
- Terraform validation
- Terraform formatting
- Ansible playbook syntax

Workflow file:

- `.github/workflows/iac_validate.yml`

## Security Notes

- `ansible/vars/secrets.yml` is encrypted with Ansible Vault.
- `*.tfvars` is ignored in `.gitignore`, which is the right place for local Terraform secrets.
- Terraform state files are currently present locally in the repository tree. For a cleaner GitHub repo, keep state out of version control and prefer a remote backend for shared work.

## Quick Start

```bash
cd terraform
terraform init
terraform apply

cd ../ansible
ansible-playbook -i inventory.ini site.yml
```

Then open:

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`
- Alertmanager: `http://localhost:9093`

## Possible Improvements

- Mount configuration files as Docker volumes instead of copying them into containers
- Add persistent volumes for Prometheus and Grafana data
- Expand Alertmanager receivers and routing
- Add Grafana dashboards, not only datasource provisioning
- Add health checks and container dependencies in Terraform
- Move Terraform state to a remote backend

## License

Add a license file if you plan to publish this repository publicly.
