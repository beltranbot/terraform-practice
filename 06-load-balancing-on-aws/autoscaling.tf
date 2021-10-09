data "aws_availability_zones" "available" {}

# define AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# key pair
resource "aws_key_pair" "my_aws_key" {
  key_name = "my_aws_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

# define autoscaling launch configuration
resource "aws_launch_configuration" "custom-launch-config" {
  name ="custom-launch-config"
  image_id = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_aws_key.key_name
  security_groups = [aws_security_group.custom-instance-sg.id]
  # this script is faulty but won't prevent the instances from launching
  user_data = "#!/bin/bash\napt-get update\napt-get -y install net-tools nginx\nMYIP=`ifconfig | grep -E '(inet addr:172)' | awk '{ print $2 }' | cut -d ':' -f 2`\necho 'Hello Team\nThis is my IP: '$MYIP > /var/www/html/index.html'"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "custom-group-autoscaling" {
  name = "custom-group-autoscaling"
  vpc_zone_identifier = [aws_subnet.customvpc-public-1.id, aws_subnet.customvpc-public-2.id]
  launch_configuration = aws_launch_configuration.custom-launch-config.name
  min_size = 2
  max_size = 2
  health_check_grace_period = 100
  health_check_type = "ELB"
  load_balancers = [aws_elb.custom-elb.name]
  force_delete = true
  tag {
    key = "Name"
    value = "custom_ece2_instance"
    propagate_at_launch = true
  }
}
