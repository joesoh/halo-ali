locals {
  project_name = "redis"
  service_name = "main"

  tags = {
    Name        = local.project_name
    Environment = terraform.workspace
    Workspace   = terraform.workspace
    Project     = local.project_name
    Terraform   = "true"
    Path        = "terraform-alibabacloud-ap-southeast-3-redis-${local.project_name}-${local.service_name}"
  }
}
resource "random_password" "password" {
  length           = 8
  special          = true
  override_special = "-"
}

module "redis" {
  source               = "terraform-alicloud-modules/redis/alicloud"
  #################
  # Redis Instance
  #################
  engine_version       = "5.0"
  instance_name        = "main-${terraform.workspace}"
  instance_class       = "redis.master.micro.default"
  vswitch_id           = "vsw-8psihfu0pq7jj48nldikk"
  security_ips         = ["127.0.0.1", "192.168.0.0/24"]
  availability_zone    = "ap-southeast-3a"
  instance_charge_type = "PostPaid"
  ssl_enable           = "Disable"
  tags = local.tags

  #################
  # Redis Accounts
  #################

  accounts = [
    {
      account_name      = "redis"
      account_password  = random_password.password.result
      account_privilege = "RoleReadWrite"
      account_type      = "Normal"
    }
  ]

  #################
  # Redis backup_policy
  #################

  backup_policy_backup_time    = "16:00Z-17:00Z"
  backup_policy_backup_period  = ["Monday", "Wednesday", "Friday"]

  #############
  # cms_alarm
  #############

  alarm_rule_name            = "CmsAlarmForRedis"
  alarm_rule_statistics      = "Average"
  alarm_rule_period          = 300
  alarm_rule_operator        = "<="
  alarm_rule_threshold       = 35
  alarm_rule_triggered_count = 2
  alarm_rule_contact_groups  = ["AccCms"]
}