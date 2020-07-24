////////////////////////////////
// templates

# Template vars are conditionally set via the `event-stream-enabled` variable.
# If true, seeds in the appropriate Chef Automate information. If false, launches the stock supervisor.
data "template_file" "jenkins_sup_service" {
  template = file("${path.module}/../templates/hab-sup.service")

  vars = {
    stream_env = var.event-stream-enabled == "true" ? var.event-stream-env-var : ""
    flags      = var.event-stream-enabled == "true" ? "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --event-stream-application=jenkins --event-stream-environment=${var.event-stream-environment} --event-stream-site=${var.aws_region} --event-stream-url=${var.automate_ip}:4222 --event-stream-token=${var.automate_token}" : "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631"
  }
}

data "template_file" "config_toml_jenkins" {
  template = file("${path.module}/../templates/config_jenkins.toml")

  vars = {
    depot_token  = var.depot_token
    admin_password   = var.jenkins_admin
    ctl_secret       = var.ctl_secret
  }
}

data "template_file" "deployment_status" {
  template = file("${path.module}/../templates/deployment_status.sh")

  vars = {
    tag_name = var.tag_name
    origin = var.origin
  }
}

data "template_file" "dep_comp" {
  template = file("${path.module}/../templates/dep_comp.sh")

  vars = {
    tag_name = var.tag_name
    origin = var.origin
  }
}

data "template_file" "health_check" {
  template = file("${path.module}/../templates/health_check.sh")

  vars = {
    tag_name = var.tag_name
    origin = var.origin
  }
}
