resource "aws_security_group" "cicd" {
  name        = "cicd_${random_id.instance_id.hex}"
  description = "base rules for cicd demo"
  vpc_id      = aws_vpc.cicd_vpc.id

  tags = {
    Name          = "${var.tag_customer}-${var.tag_project}_${random_id.instance_id.hex}_${var.tag_application}_security_group"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Application = var.tag_application
    X-Contact     = var.tag_contact
    X-TTL         = var.tag_ttl
  }
}

//////////////////////////
// cicd SG Rules 
resource "aws_security_group_rule" "jenkins_ingress_allow_22_tcp_all" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cicd.id
}

resource "aws_security_group_rule" "jenkins_ingress_allow_80_tcp_all" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cicd.id
}

resource "aws_security_group_rule" "jenkins_ingress_allow_9631_tcp_all" {
  type              = "ingress"
  from_port         = 9631
  to_port           = 9631
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cicd.id
}

resource "aws_security_group_rule" "jenkins_ingress_allow_3389_tcp_all" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cicd.id
}

resource "aws_security_group_rule" "jenkins_ingress_allow_9999_tcp_all" {
  type              = "ingress"
  from_port         = 9999
  to_port           = 9999
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cicd.id
}

# Egress: ALL
resource "aws_security_group_rule" "linux_jenkins_egress_allow_0-65535_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cicd.id
}
