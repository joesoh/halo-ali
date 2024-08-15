terraform {
  required_version = "~> 1.7.3"

  backend "oss" {
    bucket              = "terraform-remote-backend-c879224a-9f05-f56d-e0ad-4e5c3f27f4e4"
    prefix              = "alibabacloud/ap-southeast-3/ecs/test-instance-staging"
    key                 = "prod/terraform.tfstate"
    acl                 = "private"
    region              = "ap-southeast-3"
    encrypt             = "true"
    tablestore_endpoint = "https://tf-oss-veri2a5e0.ap-southeast-3.ots.aliyuncs.com"
    tablestore_table    = "terraform_remote_backend_lock_table_c879224a_9f05_f56d_e0ad_4e5c3f27f4e4"
  }
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = ">= 1.225.0"
    }
  }
}