# Resource-10: Creat Security Group for the Bationhost
resource "aws_security_group" "Bastionhost-SG" {
  name        = "Bastionhost-SG"
  description = "Allow only port 22"
  vpc_id      = aws_vpc.CSD-VPC.id

  ingress    {
      description      = "SSH Connection"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  egress     {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  tags = {
    Name = "Bastionhost-SG"
  }
}

# Resource-11: Creat Amazon Linux 2 VM instance and call it "Bastionhost-server" in pub sbn
resource "aws_instance" "Bastionhost-server" {
  ami           = "ami-0a606d8395a538502"
  instance_type = "t2.micro"
  key_name      = "XXXXXXXXXXXX"
  subnet_id     = aws_subnet.CSD-VPC-Pub-sbn.id
  vpc_security_group_ids = [aws_security_group.Bastionhost-SG.id]

  tags = {
    Name = "Bastionhost-server"
  }

  # Copies the file as the root user using SSH
provisioner "file" {
  source      = "./app"
  destination = "/home/ec2-user"
  }

provisioner "remote-exec" {
    inline = [
    "sudo yum update -y"
    ]
  }

connection {
  type     = "ssh"
  user     = "ec2-user"
  host     = self.public_ip
  private_key = file("ec2-keypair/XXXXXXXXXXXX.pem")
  }
}

# Indexing
 #    0               1               2
# [instancetype-1, intancetype-2, instancetype-3]

# Resource-12: Creat Security Group for the AppDB server using S.G referential
resource "aws_security_group" "AppDB-SG" {
  name        = "AppDB-SG"
  description = "Allow only port 22"
  vpc_id      = aws_vpc.CSD-VPC.id

  ingress    {
      description      = "SSH Connection"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      security_groups = ["${aws_security_group.Bastionhost-SG.id}"]
    }

  egress     {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  tags = {
    Name = "AppDB-SG"
  }
}

# Resource-13: Create an Amazon Linux 2 VM instance and call it "AppDB-server" in prv sbn
resource "aws_instance" "AppDB-server" {
  ami           = "ami-0a606d8395a538502"
  instance_type = "t2.micro"
  key_name      = "XXXXXXXXXXXX"
  subnet_id     = aws_subnet.CSD-VPC-Prv-sbn.id
  vpc_security_group_ids = [aws_security_group.AppDB-SG.id]

  tags = {
    Name = "AppDB-server"
  }
}

output "private_ip" {
  value = aws_instance.AppDB-server.*.private_ip
}

output "public_ip" {
  value = aws_instance.Bastionhost-server.*.public_ip
}