resource "aws_instance" "vpc_jumpbox" {
    ami = "${var.rhel_ami}"
    availability_zone = "${var.az}"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    security_groups = [ "${aws_security_group.ssh_world.id}" ]
    subnet_id = "${aws_subnet.subnet-pub.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "vpc_jumpbox"
    }
    connection {
      user = "ec2-user"
      key_file = "${var.aws_key_path}"
    }
    provisioner "remote-exec" {
      inline = [
      "sudo yum install wget git unzip -y",
      "sudo mkdir /opt/terraform",
      "sudo wget https://releases.hashicorp.com/terraform/0.6.14/terraform_0.6.14_linux_amd64.zip -P /opt/terraform/",
      "sudo unzip /opt/terraform/terraform_0.6.14_linux_amd64.zip -d /opt/terraform",
      "sudo rm -rf /opt/terraform/terraform_0.6.14_linux_amd64.zip",
      "sudo ln -s /opt/terraform/terraform /usr/bin/terraform"
      ]
    }
}
