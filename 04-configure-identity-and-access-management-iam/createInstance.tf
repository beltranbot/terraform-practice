data "aws_availability_zones" "available" {}

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

resource "aws_key_pair" "my_aws_key" {
  key_name   = "my_aws_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "myFirstInstance" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t2.micro"
  availability_zone    = data.aws_availability_zones.available.names[0]
  key_name             = aws_key_pair.my_aws_key.key_name
  iam_instance_profile = aws_iam_instance_profile.s3-bucket-role-instance-profile.name
  tags = {
    Name = "custom_instance"
  }
}

output "public_ip" {
  value = aws_instance.myFirstInstance.public_ip
}
