resource "aws_instance" "vpn_endpoint" {
    ami = "${var.rhel_ami}"
    availability_zone = "${var.az}"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    security_groups = [ "${aws_security_group.public_access.id}" ]
    subnet_id = "${aws_subnet.subnet-pub.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "${var.vpc_name} vpn endpoint"
    }
    connection {
      user = "ec2-user"
      key_file = "${var.aws_key_path}"
    }
    provisioner "remote-exec" {
      inline = [
      "sudo yum install git -y",
      "mkdir -p ~/cookbooks/ctt_docker",
      "git clone https://github.com/christianTragesser/cookbook-ctt_docker.git ~/cookbooks/ctt_docker",
      "cd ~/cookbooks/ctt_docker && berks install",
      "cd ~/cookbooks/ctt_docker && berks vendor ~/cookbooks",
      "sudo chef-client -z -o ctt_docker::default"
      ]
    }
}