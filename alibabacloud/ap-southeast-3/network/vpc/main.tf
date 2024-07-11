variable "profile" {
  default = "verity"
}
variable "region" {
  default = "ap-southeast-3"
}
provider "alicloud" {
  region  = var.region
  profile = var.profile
}


module "vpc" {
  source  = "alibaba/vpc/alicloud"
  version = "1.10.0"
  region  = var.region
  profile = var.profile

  vpc_name = "vpc-${terraform.workspace}"

  vpc_cidr          = var.vpc_cidr
  resource_group_id = var.resource_group_id


  availability_zones = var.availability_zones
  vswitch_cidrs      = var.vswitch_cidrs

  vswitch_name = "VSwitch-${terraform.workspace}-"

  vpc_tags = {
    Environment = terraform.workspace
  }

  vswitch_tags = {
    Environment = terraform.workspace
  }
}