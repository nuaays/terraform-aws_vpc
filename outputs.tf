output "name" {
  value = "${aws_vpc.default.tags.Name}"
}
output "subnet-pub" {
  value = "${aws_subnet.subnet-pub.id}"
}
output "subnet-priv" {
    value = "${aws_subnet.subnet-priv.id}"
}
output "id" {
    value = "${aws_vpc.default.id}"
}
output "cidr_block" {
    value = "${aws_vpc.default.cidr_block}"
}
output "default_route_table_id" {
    value = "${aws_vpc.default.default_route_table_id}"
}
output "default_network_acl_id" {
    value = "${aws_vpc.default.default_network_acl_id}"
}
output "default_security_group_id" {
    value = "${aws_vpc.default.default_security_group_id}"
}
output "ssh_world_security_group_id" {
    value = "${aws_security_group.ssh_world.id}"
}
output "ssh_vpc_security_group_id" {
    value = "${aws_security_group.ssh_vpc.id}"
}
