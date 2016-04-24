resource "aws_vpc" "ctt" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = false
    tags {
        Name = "ctt"
    }
}
