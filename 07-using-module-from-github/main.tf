# use the module in github
module "ec2_cluster" {
  # copy and paste the source from the Github and remove the https://
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"
  name = "my-cluster"
  ami = "ami-02e136e904f3da870"
  instance_type = "t2.micro"
  subnet_id = "subnet-05631dd3edea78639"
  tags = {
    terraform = true
    environment = "dev"
  }
}
