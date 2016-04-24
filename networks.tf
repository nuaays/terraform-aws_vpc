resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.ctt.id}"
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
        cidr_blocks = ["${var.subnet-priv0_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.subnet-priv0_cidr}"]
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
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    vpc_id = "${aws_vpc.ctt.id}"

    tags {
        Name = "NATSG"
    }
}
resource "aws_instance" "nat" {
    ami = "ami-030f4133" # this is a special ami preconfigured to do NAT
    availability_zone = "${var.vpc_region}b"
    instance_type = "t1.micro"
    key_name = "${var.aws_key_name}"
    security_groups = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.subnet-pub255.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "VPC NAT"
    }
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.nat.id}"
    vpc = true
}
/*
  Public Subnet
*/

resource "aws_subnet" "subnet-pub255" {
        vpc_id = "${aws_vpc.ctt.id}"

        cidr_block = "${var.subnet-pub255_cidr}"
        availability_zone = "${var.vpc_region}b"
        map_public_ip_on_launch = true
        tags {
            Name = "subnet-pub255"
        }
}

resource "aws_route_table" "route-default" {
  vpc_id = "${aws_vpc.ctt.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "route-default"
  }
}
resource "aws_route_table_association" "route-default" {
  subnet_id = "${aws_subnet.subnet-pub255.id}"
  route_table_id = "${aws_route_table.route-default.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "subnet-priv0" {
    vpc_id = "${aws_vpc.ctt.id}"

    cidr_block = "${var.subnet-priv0_cidr}"
    availability_zone = "${var.vpc_region}a"

    tags {
        Name = "subnet-priv0"
    }
}

resource "aws_route_table" "route-priv0" {
    vpc_id = "${aws_vpc.ctt.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }
    tags {
        Name = "route-priv0"
    }
}
resource "aws_route_table_association" "route-priv0" {
    subnet_id = "${aws_subnet.subnet-priv0.id}"
    route_table_id = "${aws_route_table.route-priv0.id}"
}
