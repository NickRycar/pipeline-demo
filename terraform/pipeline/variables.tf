////////////////////////////////
// AWS Connection

variable "aws_profile" {
}

variable "aws_region" {
  default = "us-west-2"
}

////////////////////////////////
// Server Settings

variable "aws_centos_image_user" {
  default = "centos"
}

variable "aws_ami_user" {
  default = "centos"
}

variable "aws_amazon_image_user" {
  default = "ec2-user"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "test_server_instance_type" {
  default = "t3.small"
}

variable "r53_matcher" {
  default = "chef-demo.com."
  description = "Matcher to find the r53 zone"
}

////////////////////////////////
// Tags

variable "tag_customer" {
}

variable "tag_project" {
}

variable "tag_name" {
}

variable "tag_dept" {
}

variable "tag_contact" {
}

variable "tag_application" {
}

variable "tag_ttl" {
  default = 4
}

variable "aws_key_pair_file" {
}

variable "aws_key_pair_name" {
}

variable "automate_server_instance_type" {
  default = "m5.xlarge"
}

variable "vpc_id" {
  default = ""
}

variable "subnet_id" {
  default = ""
}

variable "node_count" {
  default = "1"
}

variable "np_prod_node_count" {
  default = "2"
}

variable "sn_prod_count" {
  default = "4"
}

////////////////////////////////
// Effortless Package Info

variable "infra_origin" {
  default = "effortless"
}

variable "infra_package" {
  default = "config-baseline"
}

variable "audit_origin" {
  default = "effortless"
}

variable "audit_package" {
  default = "audit-baseline"
}

variable "group" {
  default = "default"
}

////////////////////////////////
// Automate Info 

variable "automate_url" {
}

variable "automate_hostname" {
}

variable "automate_token" {
}

variable "automate_user" {
}

variable "automate_ip" {
}

////////////////////////////////
// Automate EAS Beta 

variable "hab_install_opts" {
  default = ""
}

variable "event-stream-enabled" {
  default = "false"
}

variable "event-stream-env-var" {
  default = "Environment=\"HAB_FEAT_EVENT_STREAM=1\""
}

variable "hab-sup-version" {
  default = "core/hab-sup"
}

variable "event-stream-environment" {
  default = "demo"
}

variable "jenkins_admin" {
  default = "admin"
}

variable "depot_token" {
}

variable "ctl_secret" {
  default = "iamsecure"
}

/////////////////////////////////////
// env vars

variable "dev_group" {
  default = "dev"
}

variable "stage_group" {
  default = "stage"
}

variable "prod_group" {
  default = "prod"
}

////////////////////////////////
// Habitat

variable "channel" {
  default = "stable"
}

variable "dev_channel" {
  default = "unstable"
}

variable "prod_channel" {
  default = "stable"
}

variable "origin" {
}

variable "update_strategy" {
  default = "at-once"
}

variable "sleep" {
  default = "60"
}
