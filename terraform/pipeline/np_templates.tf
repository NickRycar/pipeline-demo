////////////////////////////////
// templates

data "template_file" "np_dev_permanent_peer" {
  template = file("${path.module}/../templates/peer-sup.service")

  # Template vars are conditionally set via the `event-stream-enabled` variable.
  # If true, seeds in the appropriate Chef Automate information. If false, launches the stock supervisor.
  vars = {
    stream_env = var.event-stream-enabled == "true" ? var.event-stream-env-var : ""
    flags      = var.event-stream-enabled == "true" ? "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --listen-ctl=0.0.0.0:9632 --permanent-peer --event-stream-application=national-parks --event-stream-environment=development --event-stream-site=${var.aws_region} --event-stream-url=${var.automate_ip}:4222 --event-stream-token=${var.automate_token}" : "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --permanent-peer"
  }
}


# Template vars are conditionally set via the `event-stream-enabled` variable.
# If true, seeds in the appropriate Chef Automate information. If false, launches the stock supervisor.
data "template_file" "np_dev_sup_service" {
  template = file("${path.module}/../templates/hab-sup.service")

  vars = {
    stream_env = var.event-stream-enabled == "true" ? var.event-stream-env-var : ""
    flags      = var.event-stream-enabled == "true" ? "--auto-update --peer ${aws_instance.np_dev_permanent_peer.private_ip} --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --event-stream-application=national-parks --event-stream-environment=development --event-stream-site=${var.aws_region} --event-stream-url=${var.automate_ip}:4222 --event-stream-token=${var.automate_token}" : "--auto-update --peer ${aws_instance.np_dev_permanent_peer.private_ip} --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631"
  }
}

////////////////////////
// Production

data "template_file" "np_prod_permanent_peer" {
  template = file("${path.module}/../templates/peer-sup.service")

  # Template vars are conditionally set via the `event-stream-enabled` variable.
  # If true, seeds in the appropriate Chef Automate information. If false, launches the stock supervisor.
  vars = {
    stream_env = var.event-stream-enabled == "true" ? var.event-stream-env-var : ""
    flags      = var.event-stream-enabled == "true" ? "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --listen-ctl=0.0.0.0:9632 --permanent-peer --event-stream-application=national-parks --event-stream-environment=production --event-stream-site=${var.aws_region} --event-stream-url=${var.automate_ip}:4222 --event-stream-token=${var.automate_token}" : "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --listen-ctl=0.0.0.0:9632 --permanent-peer"
  }
}


# Template vars are conditionally set via the `event-stream-enabled` variable.
# If true, seeds in the appropriate Chef Automate information. If false, launches the stock supervisor.
data "template_file" "np_prod_sup_service" {
  template = file("${path.module}/../templates/hab-sup.service")

  vars = {
    stream_env = var.event-stream-enabled == "true" ? var.event-stream-env-var : ""
    flags      = var.event-stream-enabled == "true" ? "--auto-update --peer ${aws_instance.np_prod_permanent_peer.private_ip} --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --event-stream-application=national-parks --event-stream-environment=production --event-stream-site=${var.aws_region} --event-stream-url=${var.automate_ip}:4222 --event-stream-token=${var.automate_token}" : "--auto-update --peer ${aws_instance.np_prod_permanent_peer.private_ip} --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631"
  }
}
