variable "name" {
  default = "office-vpn"
}

variable "spec" {
  default = "100"
}

data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

data "alicloud_vpcs" "default" {
  name_regex = "^vpc-management$"
  cidr_block = "10.64.0.0/16"
}

data "alicloud_vswitches" "default0" {
  vpc_id  = data.alicloud_vpcs.default.ids.0
  zone_id = data.alicloud_zones.default.ids.0
}

data "alicloud_vswitches" "default1" {
  vpc_id  = data.alicloud_vpcs.default.ids.0
  zone_id = data.alicloud_zones.default.ids.1
}

resource "alicloud_vpn_gateway" "default" {
  vpn_type         = "Normal"
  vpn_gateway_name = var.name

  vswitch_id                   = data.alicloud_vswitches.default0.ids.0
  disaster_recovery_vswitch_id = data.alicloud_vswitches.default1.ids.0
  auto_pay                     = true
  vpc_id                       = data.alicloud_vpcs.default.ids.0
  network_type                 = "public"
  payment_type                 = "PayAsYouGo"
  enable_ipsec                 = true
  bandwidth                    = var.spec
}

resource "alicloud_vpn_customer_gateway" "default" {
  description           = var.name
  ip_address            = "202.186.4.162"
  asn                   = "1219002"
  customer_gateway_name = var.name
}

resource "alicloud_vpn_connection" "default" {
  vpn_gateway_id      = alicloud_vpn_gateway.default.id
  vpn_connection_name = var.name
  local_subnet = [
    "10.64.0.0/14" # 10.64.0.1 - 10.67.255.254
  ]
  remote_subnet = [
    "192.168.20.0/23"
  ]
  tags = {
    Created = "TF"
    For     = "example"
  }
  enable_tunnels_bgp = "false"
  tunnel_options_specification {
    tunnel_ipsec_config {
      ipsec_auth_alg = "sha256"
      ipsec_enc_alg  = "aes256"
      ipsec_lifetime = "3600"
      ipsec_pfs      = "group14"
    }

    customer_gateway_id = alicloud_vpn_customer_gateway.default.id
    role                = "master"
    # tunnel_bgp_config {
    #   local_asn    = "1219002"
    #   tunnel_cidr  = "169.254.30.0/30"
    #   local_bgp_ip = "169.254.30.1"
    # }

    tunnel_ike_config {
      ike_mode     = "aggressive"
      ike_version  = "ikev2"
      local_id     = "47.250.149.119"
      psk          = "pvki-esaq-5qda-cfzz"
      remote_id    = "202.186.4.162"
      ike_auth_alg = "sha256"
      ike_enc_alg  = "aes256"
      ike_lifetime = "28800"
      ike_pfs      = "group14"
    }

  }
  tunnel_options_specification {
    tunnel_ike_config {
      remote_id    = "remote24"
      ike_enc_alg  = "aes256"
      ike_lifetime = "28800"
      ike_mode     = "aggressive"
      ike_pfs      = "group14"
      ike_auth_alg = "sha256"
      ike_version  = "ikev2"
      local_id     = "localid_tunnel2"
      psk          = "pvki-esaq-5qda-cfzz"
    }

    tunnel_ipsec_config {
      ipsec_lifetime = "2700"
      ipsec_pfs      = "group14"
      ipsec_auth_alg = "sha256"
      ipsec_enc_alg  = "aes256"
    }

    customer_gateway_id = alicloud_vpn_customer_gateway.default.id
    role                = "slave"
    # tunnel_bgp_config {
    #   local_asn    = "1219002"
    #   local_bgp_ip = "169.254.40.1"
    #   tunnel_cidr  = "169.254.40.0/30"
    # }
  }
}