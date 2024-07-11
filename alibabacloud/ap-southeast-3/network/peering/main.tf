provider "alicloud" {
  region = "ap-southeast-3"
}

data "alicloud_account" "default" {}

data "alicloud_vpcs" "management" {
  status     = "Available"
  name_regex = "^vpc-management"
}

data "alicloud_vpcs" "staging" {
  status     = "Available"
  name_regex = "^vpc-staging"
}

data "alicloud_vpcs" "production" {
  status     = "Available"
  name_regex = "^vpc-production"
}

resource "alicloud_vpc_peer_connection" "management_staging" {
  peer_connection_name = "management_staging"
  accepting_ali_uid    = data.alicloud_account.default.id
  vpc_id               = data.alicloud_vpcs.management.vpcs.0.id
  accepting_region_id  = "ap-southeast-3"
  accepting_vpc_id     = data.alicloud_vpcs.staging.vpcs.0.id
  description          = "vpc peering management_staging"
}

resource "alicloud_vpc_peer_connection" "management_production" {
  peer_connection_name = "management_production"
  accepting_ali_uid    = data.alicloud_account.default.id
  vpc_id               = data.alicloud_vpcs.management.vpcs.0.id
  accepting_region_id  = "ap-southeast-3"
  accepting_vpc_id     = data.alicloud_vpcs.production.vpcs.0.id
  description          = "vpc peering management_production"
}

resource "alicloud_route_entry" "management_staging" {
  route_table_id        = data.alicloud_vpcs.management.vpcs.0.route_table_id
  destination_cidrblock = data.alicloud_vpcs.staging.vpcs.0.cidr_block
  nexthop_id            = alicloud_vpc_peer_connection.management_staging.id
  nexthop_type          = "VpcPeer"
}

resource "alicloud_route_entry" "management_production" {
  route_table_id        = data.alicloud_vpcs.management.vpcs.0.route_table_id
  destination_cidrblock = data.alicloud_vpcs.production.vpcs.0.cidr_block
  nexthop_id            = alicloud_vpc_peer_connection.management_production.id
  nexthop_type          = "VpcPeer"
}
