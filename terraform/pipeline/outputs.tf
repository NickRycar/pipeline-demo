output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "np_dev_permanent_peer_DNS_name" {
  value = "${aws_route53_record.np-peer-dev.name}.chef-demo.com"
}

output "np_dev_permanent_peer_public_ip" {
  value = aws_instance.np_dev_permanent_peer.public_ip
}

output "np_dev_mongodb_public_ip" {
  value = aws_instance.np_dev_mongodb.public_ip
}

output "np_dev_national_parks_public_ips" {
  value = join(",", aws_instance.np_dev_national_parks.*.public_ip)
}

output "np_dev_haproxy_public_ip" {
  value = aws_instance.np_dev_haproxy.public_ip
}

output "sn_dev_sample_node_app_public_ips" {
  value = join(",", aws_instance.sn_dev_sample_node_app.*.public_ip)
}

output "sn_prod_canary_sample_node_app_public_ips" {
  value = join(",", aws_instance.sn_prod_canary_sample_node_app.*.public_ip)
}

output "sn_prod_50_sample_node_app_public_ips" {
  value = join(",", aws_instance.sn_prod_50_sample_node_app.*.public_ip)
}

output "sn_prod_100_sample_node_app_public_ips" {
  value = join(",", aws_instance.sn_prod_100_sample_node_app.*.public_ip)
}


# output "jenkins_password" {
#   value = data.external.jenkins_secrets.result["jenkins_pw"]
# }

output "np_prod_haproxy_public_ip" {
  value = aws_instance.np_prod_haproxy.public_ip
}

output "np_prod_blue_national_parks_public_ips" {
  value = join(",", aws_instance.np_prod_national_parks_blue.*.public_ip)
}

output "np_prod_green_national_parks_public_ips" {
  value = join(",", aws_instance.np_prod_national_parks_green.*.public_ip)
}

output "np_prod_mongodb_public_ips" {
  value = join(",", aws_instance.np_prod_mongodb.*.public_ip)
}

output "np_prod_unmanaged_public_ips" {
  value = join(",", aws_instance.np_prod_unmanaged.*.public_ip)
}
