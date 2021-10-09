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

# define key pair
resource "aws_key_pair" "my_aws_key" {
  key_name   = "my_aws_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

# define autoscaling launch configuration
resource "aws_launch_configuration" "custom-launch-config" {
  name          = "custom-launch-config"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_aws_key.key_name
}

# define autoscaling group
resource "aws_autoscaling_group" "custom-group-autoscaling" {
  name = "custom-group-autoscaling"
  vpc_zone_identifier = ["subnet-05631dd3edea78639"] #
  launch_configuration      = aws_launch_configuration.custom-launch-config.name
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 100
  health_check_type         = "EC2"
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "custom_ec2_instance"
    propagate_at_launch = true
  }
}

# define autoscaling configuration policy
resource "aws_autoscaling_policy" "custom-cpu-policy" {
  name                   = "custom-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.custom-group-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

# define cloud watch monitoring
resource "aws_cloudwatch_metric_alarm" "custom-cpu-alarm" {
  alarm_name          = "custom-cpu-alarm"
  alarm_description   = "alarm once cpu usage increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.custom-group-autoscaling.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.custom-cpu-policy.arn]
}

# define auto descaling policy
resource "aws_autoscaling_policy" "custom-cpu-policy-scaledown" {
  name                   = "custom-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.custom-group-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

# define descaling cloud watch
resource "aws_cloudwatch_metric_alarm" "custom-cpu-alarm-scaledown" {
  alarm_name          = "custom-cpu-alarm-scaledown"
  alarm_description   = "alarm once cpu usage decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 10

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.custom-group-autoscaling.arn
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.custom-cpu-policy-scaledown.arn]
}
