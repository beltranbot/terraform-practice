module "dev-vpc" {
  source                         = "../../08-creating-a-custom-module"
  vpcname                        = "dev01-vpc"
  cidr                           = "10.0.2.0/24"
  enable_dns_support             = true
  enable_classiclink             = false
  enable_classiclink_dns_support = true
  enable_ipv6                    = true
  vpcenvironment                 = "dev"
}
