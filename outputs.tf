output "vpc_name" {
  value = "${aws_vpc.module.tags.Name}"
}
output "subnet-public" {
  value = "${aws_subnet.subnet-pub.id}"
}
output "subnet-private" {
    value = "${aws_subnet.subnet-priv.id}"
}
output "vpc_id" {
    value = "${aws_vpc.module.id}"
}
output "vpc_cidr_block" {
    value = "${aws_vpc.module.cidr_block}"
}
output "default_route_table_id" {
    value = "${aws_vpc.module.default_route_table_id}"
}
output "default_network_acl_id" {
    value = "${aws_vpc.module.default_network_acl_id}"
}
output "default_security_group_id" {
    value = "${aws_vpc.module.default_security_group_id}"
}
output "public_access_security_group_id" {
    value = "${aws_security_group.public_access.id}"
}
output "ssh_vpc_security_group_id" {
    value = "${aws_security_group.ssh_vpc.id}"
}
output "vpn_endpoint_public_ip" {
    value = "${aws_instance.vpn_endpoint.public_ip}"
}
