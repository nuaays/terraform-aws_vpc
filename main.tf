provider "aws" {
        access_key = "${var.aws_access_key}"
        secret_key = "${var.aws_secret_key}"
        region = "${var.aws_region}"
}

resource "aws_vpc" "module" {
  cidr_block = "${var.network_prefix}.0.0/16"
  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.module.id}"
  tags {
    Name = "default_gw"
  }
}

/*
  NAT Instance
*/
resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.subnet-priv_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.subnet-priv_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
   ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${aws_vpc.module.cidr_block}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = "${aws_vpc.module.id}"

    tags {
        Name = "NATSG"
    }
}
resource "aws_instance" "nat" {
    ami = "ami-030f4133" # this is a special ami preconfigured to do NAT
    availability_zone = "${var.az}"
    instance_type = "t1.micro"
    key_name = "${var.aws_key_name}"
    security_groups = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.subnet-pub.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "${var.vpc_name} VPC NAT"
    }
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.nat.id}"
    vpc = true
}
/*
  Public Subnet
*/

resource "aws_subnet" "subnet-pub" {
        vpc_id = "${aws_vpc.module.id}"

        cidr_block = "${var.subnet-pub_cidr}"
        availability_zone = "${var.az}"
        map_public_ip_on_launch = true
        tags {
            Name = "subnet-pub"
        }
}

resource "aws_route_table" "route-default" {
  vpc_id = "${aws_vpc.module.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "route-default"
  }
}
resource "aws_route_table_association" "route-default" {
  subnet_id = "${aws_subnet.subnet-pub.id}"
  route_table_id = "${aws_route_table.route-default.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "subnet-priv" {
    vpc_id = "${aws_vpc.module.id}"

    cidr_block = "${var.subnet-priv_cidr}"
    availability_zone = "${var.az}"

    tags {
        Name = "subnet-priv"
    }
}

resource "aws_route_table" "route-priv" {
    vpc_id = "${aws_vpc.module.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }
    tags {
        Name = "route-priv"
    }
}
resource "aws_route_table_association" "route-priv" {
    subnet_id = "${aws_subnet.subnet-priv.id}"
    route_table_id = "${aws_route_table.route-priv.id}"
}
resource "aws_security_group" "ssh_world" {
  name = "ssh_world"
  description = "everyone by TCP 22"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.module.id}"
  tags {
    Name = "ssh_world"
  }
}

resource "aws_security_group" "ssh_vpc" {
  name = "ssh_vpc"
  description = "all vpc by TCP 22"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_vpc.module.cidr_block}"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.module.id}"
  tags {
    Name = "ssh_vpc"
  }
}
