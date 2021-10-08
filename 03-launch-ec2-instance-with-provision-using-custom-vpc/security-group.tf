resource "aws_security_group" "allow-customvpc-ssh" {
  vpc_id      = aws_vpc.customvpc.id
  name        = "allow-customvpc-ssh"
  description = "security group that allows ssh connections"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my-ip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-customvpc-ssh"
  }
}

resource "aws_security_group" "allow-customvpc-http" {
  vpc_id      = aws_vpc.customvpc.id
  name        = "allow-customvpc-http"
  description = "security group that allows http connections"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-customvpc-http"
  }
}
