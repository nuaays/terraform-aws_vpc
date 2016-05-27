resource "aws_instance" "vpn_endpoint" {
    ami = "${var.mod_rhel_ami}"
    availability_zone = "${var.mod_az}"
    instance_type = "t2.micro"
    key_name = "${var.mod_aws_key_name}"
    security_groups = [ "${aws_security_group.public_access.id}" ]
    subnet_id = "${aws_subnet.subnet-pub.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "${var.mod_vpc_name} vpn endpoint"
    }
    connection {
      user = "ec2-user"
      key_file = "${var.mod_aws_key_path}"
    }
    provisioner "remote-exec" {
      inline = [
      "sudo yum install git -y",
      "mkdir -p ~/cookbooks/ctt_ovpn",
      "git clone https://github.com/christianTragesser/cookbook-ctt_ovpn.git ~/cookbooks/ctt_ovpn",
      "cd ~/cookbooks/ctt_ovpn && berks install",
      "cd ~/cookbooks/ctt_ovpn && berks vendor ~/cookbooks",
      "sudo chef-client -z -o ctt_ovpn::default"
      ]
    }
}
resource "null_resource" "module_dependency" {
  depends_on = ["aws_instance.vpn_endpoint"]
}
