# Launch var.node_count CentOS instances for cicd Demos
resource "aws_instance" "jenkins" {
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.aws_ami_user
    private_key = file(var.aws_key_pair_file)
  }

  ami                         = data.aws_ami.centos.id
  instance_type               = var.instance_type
  key_name                    = var.aws_key_pair_name
  subnet_id                   = aws_subnet.cicd_subnet.id
  vpc_security_group_ids      = [aws_security_group.cicd.id]
  associate_public_ip_address = true

  tags = {
    Name          = "jenkins_${random_id.instance_id.hex}"
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
    content     = data.template_file.jenkins_sup_service.rendered
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

  provisioner "file" {
    content     = data.template_file.config_toml_jenkins.rendered
    destination = "/home/${var.aws_ami_user}/config_jenkins.toml"
  }

  provisioner "file" {
    # source      = "files/deployment_status.sh"
    content     = data.template_file.deployment_status.rendered
    destination = "/home/${var.aws_ami_user}/deployment_status.sh"
  }

  provisioner "file" {
    # source      = "files/health_check.sh"
    content     = data.template_file.health_check.rendered
    destination = "/home/${var.aws_ami_user}/health_check.sh"
  }
  
  provisioner "file" {
    # source      = "files/dep_comp.sh"
    content     = data.template_file.dep_comp.rendered
    destination = "/home/${var.aws_ami_user}/dep_comp.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname jenkins",
      "sudo yum install -y epel-release",
      "sudo yum install -y jq curl",
      "sudo mv /home/${var.aws_ami_user}/deployment_status.sh /usr/local/bin/deployment_status.sh",
      "sudo mv /home/${var.aws_ami_user}/health_check.sh /usr/local/bin/health_check.sh",
      "sudo mv /home/${var.aws_ami_user}/dep_comp.sh /usr/local/bin/dep_comp.sh",
      "sudo chmod +x /usr/local/bin/*.sh",
      "curl -L https://omnitruck.chef.io/install.sh | sudo bash",
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
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo mkdir -p /hab/user/${var.infra_package}/config /hab/user/${var.audit_package}/config /hab/user/jenkins/config",
      "sudo cp /home/${var.aws_ami_user}/audit_linux.toml /hab/user/${var.audit_package}/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_linux.toml /hab/user/${var.infra_package}/config/user.toml",
      "sudo cp /home/${var.aws_ami_user}/config_jenkins.toml /hab/user/jenkins/config/user.toml",
      # Comment out until I can skip the ip forward harden, and create an audit wavier
      #"sudo hab svc load ${var.infra_origin}/${var.infra_package} --channel stable --strategy at-once",
      #"sudo hab svc load ${var.audit_origin}/${var.audit_package} --channel stable -- strategy at-once",
      "sudo hab svc load nrycar/jenkins --channel stable"
    ]
  }
}

# data "external" "jenkins_secrets" {
#   program    = ["bash", "${path.module}/data-sources/get-jenkins-pw.sh"]
#   depends_on = [aws_instance.jenkins]

#   query = {
#     ssh_user = "centos"
#     ssh_key  = var.aws_key_pair_file
#     jenkins_ip    = aws_instance.jenkins.public_ip
#   }
# }
