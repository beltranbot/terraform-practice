# AWS ELB config
resource "aws_elb" "custom-elb" {
  name = "custom-elb"
  subnets = [aws_subnet.customvpc-public-1.id, aws_subnet.customvpc-public-2.id]
  security_groups = [aws_security_group.custom-elb-sg.id]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    # (required) The number of checks before the instance is declared healthy
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }

  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400

  tags = {
    Name = "custom-elb"
  }
}

# security group for AWS ELB
resource "aws_security_group" "custom-elb-sg" {
  vpc_id = aws_vpc.customvpc.id
  name = "custom-elb-sg"
  description = "security group for ELB"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "custom-elb-sg"
  }
}

# security group for instances
resource "aws_security_group" "custom-instance-sg" {
  vpc_id = aws_vpc.customvpc.id
  name = "custom-instance-sg"
  description = "security group for instances"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.custom-elb-sg.id]
  }

  tags = {
    Name = "custom-instance-sg"
  }
}
