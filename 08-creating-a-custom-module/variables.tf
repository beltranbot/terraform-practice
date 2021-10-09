# vpc variables
variable "cidr" {
  type = string
  description = "The CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "instance_tenancy" {
  type = string
  description = "A tenancy option for instances launched into the VPC"
  default = "default"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type = bool
  default = false
}

variable "enable_dns_support" {
  type = bool
}

variable "enable_classiclink" {
  type = bool
}

variable "enable_classiclink_dns_support" {
  type = bool
}

variable "enable_ipv6" {
  type = bool
}

variable "vpcname" {
  type = string
}

variable "vpcenvironment" {
  type = string
}
