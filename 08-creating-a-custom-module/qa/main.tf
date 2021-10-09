module "qa-vpc" {
  source                         = "../../08-creating-a-custom-module"
  vpcname                        = "qa01-vpc"
  cidr                           = "10.0.3.0/24"
  enable_dns_support             = true
  enable_classiclink             = false
  enable_classiclink_dns_support = true
  enable_ipv6                    = true
  vpcenvironment                 = "qa"
}
