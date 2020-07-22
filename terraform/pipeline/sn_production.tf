resource "aws_instance" "sn_prod_permanent_peer" {
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
    Name          = "sn_prod_permanent_peer_${random_id.instance_id.hex}"
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
    content     = data.template_file.audit_toml_linux_prod.rendered
    destination = "/home/${var.aws_ami_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = data.template_file.config_toml_linux_prod.rendered
    destination = "/home/${var.aws_ami_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname sn_prod_permanent-peer",
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
      "sudo hab svc load ${var.infra_origin}/${var.infra_package} --group ${var.prod_group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.prod_group} --strategy at-once --channel stable",
    ]
  }
}

# National Parks instances peered with the permanent peer and binded to mongodb instance
resource "aws_instance" "sn_prod_canary_sample_node_app" {
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
  count                       = 1

  tags = {
    Name          = "sn_prod_canary_sample_node_app_${random_id.instance_id.hex}"
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
    content     = data.template_file.sn_prod_sup_service.rendered
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = data.template_file.audit_toml_linux_prod.rendered
    destination = "/home/${var.aws_ami_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = data.template_file.config_toml_linux_prod.rendered
    destination = "/home/${var.aws_ami_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname sn_prod_canary_sample-node-app-${count.index}",
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
      "sudo hab svc load ${var.infra_origin}/${var.infra_package} --group ${var.prod_group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.prod_group} --strategy at-once --channel stable",
      "sudo hab svc load ${var.origin}/sample-node-app --group prod-canary --channel prod-canary --strategy ${var.update_strategy}",
    ]
  }
}

resource "aws_instance" "sn_prod_50_sample_node_app" {
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
  count                       = 1

  tags = {
    Name          = "sn_prod_50_sample_node_app_${random_id.instance_id.hex}"
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
    content     = data.template_file.sn_prod_sup_service.rendered
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = data.template_file.audit_toml_linux_prod.rendered
    destination = "/home/${var.aws_ami_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = data.template_file.config_toml_linux_prod.rendered
    destination = "/home/${var.aws_ami_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname sn_prod_50_sample-node-app-${count.index}",
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
      "sudo hab svc load ${var.infra_origin}/${var.infra_package} --group ${var.prod_group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.prod_group} --strategy at-once --channel stable",
      "sudo hab svc load ${var.origin}/sample-node-app --group prod-50 --channel prod-50 --strategy ${var.update_strategy}",
    ]
  }
}

resource "aws_instance" "sn_prod_100_sample_node_app" {
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
  count                       = var.sn_prod_count / 2

  tags = {
    Name          = "sn_prod_100_sample_node_app_${random_id.instance_id.hex}"
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
    content     = data.template_file.sn_prod_sup_service.rendered
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = data.template_file.audit_toml_linux_prod.rendered
    destination = "/home/${var.aws_ami_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = data.template_file.config_toml_linux_prod.rendered
    destination = "/home/${var.aws_ami_user}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname sn_prod_100_sample-node-app-${count.index}",
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
      "sudo hab svc load ${var.infra_origin}/${var.infra_package} --group ${var.prod_group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.prod_group} --strategy at-once --channel stable",
      "sudo hab svc load ${var.origin}/sample-node-app --group ${var.prod_group} --channel prod --strategy ${var.update_strategy}",
    ]
  }
}

resource "aws_instance" "sn_prod_haproxy" {
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
    Name          = "sn_prod_haproxy_${random_id.instance_id.hex}"
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
    content     = data.template_file.sn_prod_sup_service.rendered
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    source      = "files/haproxy_sn.toml"
    destination = "/home/${var.aws_ami_user}/haproxy.toml"
  }

  provisioner "file" {
    content     = data.template_file.audit_toml_linux_prod.rendered
    destination = "/home/${var.aws_ami_user}/audit_linux.toml"
  }

  provisioner "file" {
    content     = data.template_file.config_toml_linux_prod.rendered
    destination = "/home/${var.aws_ami_user}/config_linux.toml"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname sn-haproxy-prod",
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
      "sudo cp /home/${var.aws_ami_user}/haproxy.toml /hab/user/haproxy/config/user.toml",
      "sudo hab svc load ${var.infra_origin}/${var.infra_package} --group ${var.prod_group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.prod_group} --strategy at-once --channel stable",
      "sudo hab svc load nrycar/haproxy --group ${var.prod_group} --bind backend-blue:sample-node-app.prod-canary --bind backend-green:sample-node-app.prod-50 --bind backend:sample-node-app.prod",
    ]
  }
}

resource "aws_route53_record" "sn-peer-prod" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.tag_name}-sn-peer-prod"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.sn_prod_permanent_peer.public_ip}"]
}

resource "aws_route53_record" "sn-haproxy-prod" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.tag_name}-sn-haproxy-prod"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.sn_prod_haproxy.public_ip}"]
}