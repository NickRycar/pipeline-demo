resource "aws_instance" "np_prod_permanent_peer" {
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
    Name          = "np_prod_permanent_peer_${random_id.instance_id.hex}"
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
    content     = data.template_file.np_prod_permanent_peer.rendered
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
      "sudo hostname np-prod-peer",
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
      "sleep ${var.sleep}",
      "sudo echo ${var.ctl_secret} > /hab/sup/default/CTL_SECRET",
      "sudo service hab-sup restart",
    ]
  }
}

# Single Mongdb instance peered with the permanent peer
resource "aws_instance" "np_prod_mongodb" {
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
  count                       = 3

  root_block_device {
    volume_size = "40"
  }

  tags = {
    Name          = "np_prod_mongodb_${random_id.instance_id.hex}"
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
    content     = data.template_file.np_prod_sup_service.rendered
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    source      = "files/mongo.toml"
    destination = "/home/${var.aws_ami_user}/mongo.toml"
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
      "sudo hostname np-mongo-prod",
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
      "sudo mkdir -p /hab/user/mongodb/config /hab/user/${var.infra_package}/config /hab/user/audit-baseline/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/${var.infra_package}/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/mongo.toml /hab/user/mongodb/config/user.toml",
      "sudo hab svc load ${var.infra_origin}/${var.infra_package} --group ${var.prod_group} --strategy at-once --channel stable",
      "sudo hab svc load effortless/audit-baseline --group ${var.prod_group} --strategy at-once --channel stable",
      "sudo hab svc load core/mongodb/3.2.10/20171016003652 --group ${var.prod_group} --topology leader",
    ]
  }
}

# National Parks instances peered with the permanent peer and binded to mongodb instance
resource "aws_instance" "np_prod_national_parks_blue" {
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
  count                       = var.np_prod_node_count / 2

  tags = {
    Name          = "np_prod_national_parks_blue_${random_id.instance_id.hex}"
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
    content     = data.template_file.np_prod_sup_service.rendered
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
      "sudo hostname national-parks-prod-blue-${count.index}",
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
      "sudo hab svc load ${var.origin}/national-parks --group prod-blue --channel prod-blue --strategy ${var.update_strategy} --bind database:mongodb.${var.prod_group}",
    ]
  }
}

resource "aws_instance" "np_prod_national_parks_green" {
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
  count                       = var.np_prod_node_count / 2

  tags = {
    Name          = "np_prod_national_parks_green_${random_id.instance_id.hex}"
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
    content     = data.template_file.np_prod_sup_service.rendered
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
      "sudo hostname national-parks-prod-green-${count.index}",
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
      "sudo hab svc load ${var.origin}/national-parks --group prod-green --channel prod-green --strategy ${var.update_strategy} --bind database:mongodb.${var.prod_group}",
    ]
  }
}

resource "aws_instance" "np_prod_unmanaged" {
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
  count                       = var.np_prod_node_count / 2

  tags = {
    Name          = "np_prod_national_parks_unmanaged_${random_id.instance_id.hex}"
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
    content     = data.template_file.np_prod_sup_service.rendered
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
      "sudo hostname national-parks-prod-unmanaged-${count.index}",
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
      "sudo mkdir -p /hab/user/haproxy/config /hab/user/dca-hardening/config /hab/user/dca-audit/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/dca-audit/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/dca-hardening/config/user.toml",
      # "sudo hab svc load ${var.infra_origin}/${var.infra_package} --group ${var.prod_group} --strategy at-once --channel stable",
      # "sudo hab svc load effortless/audit-baseline --group ${var.prod_group} --strategy at-once --channel stable",
      # "sudo hab svc load ${var.origin}/national-parks --group prod-green --channel prod-green --strategy ${var.update_strategy} --bind database:mongodb.${var.prod_group}",
    ]
  }
}

# HAProxy instance peered with permanent peer and binded to the national-parks instance
resource "aws_instance" "np_prod_haproxy" {
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
    Name          = "np_prod_haproxy_${random_id.instance_id.hex}"
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
    content     = data.template_file.np_prod_sup_service.rendered
    destination = "/home/${var.aws_ami_user}/hab-sup.service"
  }

  provisioner "file" {
    source      = "files/haproxy.toml"
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
      "sudo hostname np-haproxy-prod",
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
      "sudo hab svc load nrycar/haproxy --group ${var.prod_group} --bind backend-blue:national-parks.prod-blue --bind backend-green:national-parks.prod-green",
    ]
  }
}

resource "aws_route53_record" "np-peer-prod" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.tag_name}-np-peer-prod"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.np_prod_permanent_peer.public_ip}"]
}

resource "aws_route53_record" "np-haproxy-prod" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.tag_name}-np-haproxy-prod"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.np_prod_haproxy.public_ip}"]
}
