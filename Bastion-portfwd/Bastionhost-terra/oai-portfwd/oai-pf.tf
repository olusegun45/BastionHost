/* Here is an example of how you can use Terraform to create port forwarding to allow you to 
SSH into a private subnet: */

resource "aws_ec2_instance" "bastion" {
  ami           = "ami-abc123"
  instance_type = "t2.micro"
  key_name      = "mykey"
  subnet_id     = "${aws_subnet.private.id}"

  tags = {
    Name = "bastion"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = "${self.public_ip}"
    private_key = "${file("~/.ssh/mykey.pem")}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'hello, world' > hello.txt",
      "echo '#!/bin/bash' > run.sh",
      "echo 'echo hello, world' > run.sh",
      "chmod +x run.sh"
    ]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH access"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_ec2_instance.bastion.id}"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}


/* This example creates an EC2 instance that will act as the bastion host in the private subnet. 
It also creates a security group that allows SSH access from any IP address, and a route 
table that directs all traffic to the bastion host.

To SSH into a private instance, you can use the bastion host as a jump box: */

/* RUN: ssh -A ec2-user@bastion_host_public_ip         ------> login to Bastion 

Then, you can SSH into the private instance using its private IP address using:

ssh ec2-user@private_instance_private_ip */
