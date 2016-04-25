resource "aws_vpc" "${var.vpc_name}" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = false
    tags {
        Name = "${var.vpc_name}"
    }
}
