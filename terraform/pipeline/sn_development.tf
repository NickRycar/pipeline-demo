resource "aws_instance" "sn_dev_permanent_peer" {
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.aws_ami_user
    private_key = file(var.aws_key_pair_file)
  }

  ami                         = data.aws_ami.centos.id
  instance_type               = var.test_server_instance_type
  key_name                    = var.aws_key_pair_name
  subnet_id                   = aws_subnet.cicd_subnet.id
  vpc_security_group_ids      = [aws_security_group.national_parks.id, aws_security_group.habitat_supervisor.id]
  associate_public_ip_address = true

  tags = {
    Name          = "sn_dev_permanent_peer_${random_id.instance_id.hex}"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Application = var.tag_application
    X-Contact     = var.tag_contact
    X-TTL         = var.tag_ttl
  }

  provisioner "file" {
    content     = data.template_file.install_hab.rendered
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = data.template_file.sn_permanent_peer.rendered
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = data.template_file.audit_toml_linux_dev.rendered
    destination = "/home/${var.aws_ami_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = data.template_file.config_toml_linux_dev.rendered
    destination = "/home/${var.aws_ami_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname sn_dev_permanent-peer",
      "sudo groupadd hab",
      "sudo adduser hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo hab license accept",
      "sudo hab pkg install ${var.hab-sup-version}",
      "sudo mv /home/${var.aws_ami_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/${var.infra_package}/config /hab/user/audit-baseline/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/${var.infra_package}/config/user.toml",
      "sudo hab svc load ${var.infra_origin}/${var.infra_package} --group ${var.dev_group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.dev_group} --strategy at-once --channel stable",
    ]
  }
}

# National Parks instances peered with the permanent peer and binded to mongodb instance
resource "aws_instance" "sn_dev_sample_node_app" {
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.aws_ami_user
    private_key = file(var.aws_key_pair_file)
  }

  ami                         = data.aws_ami.centos.id
  instance_type               = var.test_server_instance_type
  key_name                    = var.aws_key_pair_name
  subnet_id                   = aws_subnet.cicd_subnet.id
  vpc_security_group_ids      = [aws_security_group.national_parks.id, aws_security_group.habitat_supervisor.id]
  associate_public_ip_address = true
  count                       = var.node_count

  tags = {
    Name          = "sn_dev_sample_node_app_${random_id.instance_id.hex}"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Application = var.tag_application
    X-Contact     = var.tag_contact
    X-TTL         = var.tag_ttl
  }

  provisioner "file" {
    content     = data.template_file.install_hab.rendered
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = data.template_file.sn_dev_sup_service.rendered
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = data.template_file.audit_toml_linux_dev.rendered
    destination = "/home/${var.aws_ami_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = data.template_file.config_toml_linux_dev.rendered
    destination = "/home/${var.aws_ami_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname sn_dev_sample-node-app-${count.index}",
      "sudo groupadd hab",
      "sudo adduser hab -g hab",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sudo hab license accept",
      "sudo hab pkg install ${var.hab-sup-version}",
      "sudo mv /home/${var.aws_ami_user}/hab-sup.service /etc/systemd/system/hab-sup.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start hab-sup",
      "sudo systemctl enable hab-sup",
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/haproxy/config /hab/user/${var.infra_package}/config /hab/user/audit-baseline/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/${var.infra_package}/config/user.toml",
      "sudo hab svc load ${var.infra_origin}/${var.infra_package} --group ${var.dev_group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.dev_group} --strategy at-once --channel stable",
      "sudo hab svc load ${var.origin}/sample-node-app --group ${var.dev_group} --channel ${var.dev_channel} --strategy ${var.update_strategy}",
    ]
  }
}

resource "aws_route53_record" "sn-peer-dev" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.tag_name}-sn-peer-dev"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.sn_dev_permanent_peer.public_ip}"]
}
