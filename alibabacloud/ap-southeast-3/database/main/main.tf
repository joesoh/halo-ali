locals {
  engine         = "MySQL"
  engine_version = "8.0"

  project_name = "main"

  tags = {
    Name        = local.project_name
    Environment = terraform.workspace
    Workspace   = terraform.workspace
    Project     = local.project_name
    Terraform   = "true"
    Path        = "terraform/alibabacloud/ap-southeast-3/database/${local.project_name}"
  }
}

module "my_sql" {
  source  = "terraform-alicloud-modules/rds/alicloud"
  version = "2.4.0"

  region = var.region
  #################
  # Rds Instance
  #################
  engine                     = local.engine
  engine_version             = local.engine_version
  instance_type              = "mysql.n2.medium.2c"
  instance_storage           = 50
  instance_storage_type      = "cloud_essd"
  instance_charge_type       = "Postpaid"
  instance_name              = "${local.project_name}-${terraform.workspace}"
  security_group_ids         = var.security_group_ids
  vswitch_id                 = "vsw-8psihfu0pq7jj48nldikk"
  security_ips               = ["192.168.0.0/16", "10.0.0.0/8"]
  tags                       = local.tags
  sql_collector_status       = var.sql_collector_status
  sql_collector_config_value = var.sql_collector_config_value
  #################
  # Rds Backup policy
  #################
  preferred_backup_period     = var.preferred_backup_period
  preferred_backup_time       = var.preferred_backup_time
  backup_retention_period     = var.backup_retention_period
  log_backup_retention_period = var.log_backup_retention_period
  enable_backup_log           = var.enable_backup_log
  #################
  # Rds Connection
  #################
  port                       = 3306
  connection_prefix          = var.connection_prefix
  allocate_public_connection = var.allocate_public_connection
  #################
  # Rds Database account
  #################
  #type           = "Super"
  privilege      = "ReadWrite"
  create_account = true
  account_name   = local.project_name
  password       = random_password.dbowner.result
  #################
  # Rds Database
  #################
  create_database = true
  databases = [
    {
      name          = "${local.project_name}",
      character_set = "utf8",
      description   = "Master database for ${local.project_name}"
    }
  ]
}

#######################
# Supporting Resources
#######################
resource "random_password" "dbowner" {
  length           = 12
  special          = true
  override_special = "-_=+"
}