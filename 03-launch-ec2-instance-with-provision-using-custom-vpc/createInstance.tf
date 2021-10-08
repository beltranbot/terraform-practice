# fetch more recent ami from a provider
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_security_groups" "default-sg" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

data "http" "my-ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_security_group_rule" "allow-myip-access-rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  description       = "allow access to this laptop ip"
  cidr_blocks       = ["${chomp(data.http.my-ip.body)}/32"]
  security_group_id = data.aws_security_groups.default-sg.ids[0]
}

resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "myfirstawsinstance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [
    aws_security_group.allow-customvpc-ssh.id,
    aws_security_group.allow-customvpc-http.id,
  ]
  subnet_id = aws_subnet.customvpc-public-1.id

  tags = {
    Name = "custom_instance1"
  }

  provisioner "file" {
    source      = "installNginx.sh"
    destination = "/tmp/installNginx.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/installNginx.sh",
      "sudo /tmp/installNginx.sh"
    ]
  }

  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.INSTANCE_USERNAME
    private_key = file(var.PATH_TO_PRIVATE_KEY)
  }
}

resource "aws_instance" "mysecondawsinstance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [
    aws_security_group.allow-customvpc-ssh.id
  ]
  subnet_id = aws_subnet.customvpc-private-1.id

  tags = {
    Name = "custom_instance2"
  }
}

output "public_ip" {
  value = aws_instance.myfirstawsinstance.public_ip
}

output "sg-id" {
  value = data.aws_security_groups.default-sg.ids[0]
}
