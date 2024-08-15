provider "alicloud" {
  region  = var.region
  profile = var.profile
}

locals {
  site_name            = "www-staging.test.com"
  vpc_id               = "vpc-8psxk6ie6mw64vstp4wrn"
  vswitch_id           = "vsw-8psihfu0pq7jj48nldikk"
  system_disk_category = "cloud_essd"
    data_disk_category = "cloud_essd"
  key_name             = "admin"
  user_data            = <<EOF
#!/bin/bash
echo "Hello Terraform!"
EOF

}

#############################################################
# create VPC, vswitch and security group
#############################################################
data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

data "alicloud_images" "ubuntu" {
  most_recent = true
  name_regex  = "^ubuntu_22.*64"
}

data "alicloud_images" "centos" {
  most_recent = true
  name_regex  = "^centos_7*"
}
// retrieve 1c2g instance type
data "alicloud_instance_types" "normal" {
  availability_zone    = "ap-southeast-3a"
  instance_type_family = "ecs.u1-c1m1"
  cpu_core_count       = 4
  memory_size          = 4
}

data "alicloud_instance_types" "prepaid" {
  availability_zone    = "ap-southeast-3a"
  instance_type_family = "ecs.n4"
  instance_charge_type = "PrePaid"
  cpu_core_count       = 1
  memory_size          = 2
}

// retrieve 1c2g instance type for Burstable instance
data "alicloud_instance_types" "t5" {
  availability_zone    = "ap-southeast-3a"
  instance_type_family = "ecs.t5"
  cpu_core_count       = 1
  memory_size          = 2
}
// retrieve 2c4g instance type for spot instance
data "alicloud_instance_types" "spot" {
  availability_zone    = "ap-southeast-3a"
  spot_strategy        = "SpotWithPriceLimit"
  cpu_core_count       = 2
  memory_size          = 4
  system_disk_category = local.system_disk_category
}
// Security Group module for ECS Module
module "security_group" {
  source  = "alibaba/security-group/alicloud"
  version = "~> 2.0"

  profile = var.profile
  region  = var.region
  name    = "test-${local.site_name}-sg"

  vpc_id = local.vpc_id

  description = "Security group which is used in test"

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      priority    = 1
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "http-80-tcp"
      priority    = 1
      cidr_blocks = "0.0.0.0/0"
    },
    {
      // Using ingress_cidr_blocks to set cidr_blocks
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Intranet SSH"
      cidr_blocks = "192.168.20.0/23,202.187.103.70/32"
      priority    = 2
    }
  ]
}

// Create a role name
resource "alicloud_ram_role" "basic" {
  name     = "test-${local.site_name}-role"
  document = <<EOF
    {
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": [
              "apigateway.aliyuncs.com",
              "ecs.aliyuncs.com"
            ]
          }
        }
      ],
      "Version": "1"
    }
  EOF
}

module "ecs" {
  source  = "alibaba/ecs-instance/alicloud"
  version = "2.11.0"
  profile = var.profile
  region  = var.region

  number_of_instances = 1

  name                        = "test-${local.site_name}"
  description                 = "An ECS instance came from site - ${local.site_name}"
  image_id                    = data.alicloud_images.ubuntu.images.0.id
  instance_type               = data.alicloud_instance_types.spot.instance_types.0.id
  key_name                    = local.key_name
  vswitch_id                  = local.vswitch_id
  security_group_ids          = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  internet_max_bandwidth_out  = 10


  #user_data = local.user_data

  system_disk_category = local.system_disk_category
  system_disk_size     = 50

  data_disks = [
    {
      name                 = "${local.site_name}-data_disk"
      category             = local.data_disk_category
      size                 = "50"
      volume_size          = 5
      encrypted            = true
      delete_with_instance = true
    }
  ]

  tags = {
    Name     = local.site_name
    Location = "Malaysia"
  }
}