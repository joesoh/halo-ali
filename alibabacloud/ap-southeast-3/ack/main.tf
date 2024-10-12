provider "alicloud" {
}

variable "k8s_name_prefix" {
  description = "The name prefix used to create ASK cluster."
  default     = "ask"
}

# The default resource names. 
locals {
  k8s_name_ask = substr(join("-", [var.k8s_name_prefix, "main", terraform.workspace]), 0, 63)
}

data "alicloud_eci_zones" "default" {}


resource "alicloud_cs_serverless_kubernetes" "serverless" {
  name                           = local.k8s_name_ask
  version                        = "1.31.1-aliyun.1" # Replace the value with the version of the cluster that you want to create. 
  cluster_spec                   = "ack.pro.small"
  vpc_id                         = "vpc-8psxk6ie6mw64vstp4wrn"
  vswitch_ids                    = ["vsw-8psihfu0pq7jj48nldikk", "vsw-8ps6g2h0wvs40b8ikeflr"]
  new_nat_gateway                = true
  endpoint_public_access_enabled = true
  deletion_protection            = true

  # Enable the RAM Roles for Service Accounts (RRSA) feature to configure service accounts. 
  enable_rrsa = true

  load_balancer_spec      = "slb.s2.small"
  time_zone               = "Asia/Shanghai"
  service_cidr            = "10.13.0.0/16"
  service_discovery_types = ["CoreDNS"]

  # tags
  tags = {
    cluster = "ack-serverless"
  }
  # addons
  addons {
    name = "nginx-ingress-controller"
    # Expose the cluster to the Internet 
    config = "{\"IngressSlbNetworkType\":\"internet\",\"IngressSlbSpec\":\"slb.s2.small\"}"
    # To expose the cluster to the Internet, specify the following configuration: 
    # config = "{\"IngressSlbNetworkType\":\"intranet\",\"IngressSlbSpec\":\"slb.s2.small\"}"
  }
  addons {
    name = "metrics-server"
  }
  addons {
    name = "knative"
  }
  addons {
    name = "managed-arms-prometheus"
  }
  addons {
    name = "logtail-ds"
    # Specify the name of a Simple Log Service project.
    # config = "{\"sls_project_name\":\"<YOUR-SLS-PROJECT-NAME>}\"}"
  }
}