locals {
  project_name = "secure"
  service_name = "api"

  vpc_id     = "vpc-8psxk6ie6mw64vstp4wrn" #staging
  vswitch_id = "vsw-8psihfu0pq7jj48nldikk" #staging-001

  staging_listener_id    = "lsn-0lopfwbkg6yaa9nxzu"
  production_listener_id = ""

  cpu    = 2
  memory = 4
  port   = "3000"

  domain_suffix     = terraform.workspace == "production" ? "" : "-staging"
  alb_rule_priority = 777

  tags = {
    Name        = local.project_name
    Environment = terraform.workspace
    Workspace   = terraform.workspace
    Project     = local.project_name
    Terraform   = "true"
    Path        = "alibabacloud-ap-southeast-3-ess-terraform"
  }
}

data "alicloud_eci_zones" "default" {}

data "alicloud_resource_manager_resource_groups" "default" {}

resource "alicloud_eip_address" "eip_address" {
  address_name = "${local.project_name}-${local.service_name}-${terraform.workspace}-eci-eip"

  tags = local.tags
}

resource "alicloud_security_group" "this" {
  vpc_id = local.vpc_id
  name   = "${local.project_name}-${local.service_name}-${terraform.workspace}-eci-sg"
}

resource "alicloud_ess_scaling_group" "this" {
  min_size           = 2
  max_size           = 4
  scaling_group_name = "${local.project_name}-${local.service_name}-${terraform.workspace}-ess"
  removal_policies   = ["OldestScalingConfiguration", "OldestInstance"]
  default_cooldown   = 5
  vswitch_ids        = [local.vswitch_id]
  group_type         = "ECI"

  lifecycle {
    ignore_changes = [desired_capacity, alb_server_group]
  }

  tags = local.tags
}

resource "alicloud_ess_eci_scaling_configuration" "this" {
  scaling_configuration_name = "${local.project_name}-${local.service_name}-${terraform.workspace}-sc"
  scaling_group_id           = alicloud_ess_scaling_group.this.id
  spot_strategy              = "SpotAsPriceGo"
  cpu                        = local.cpu
  memory                     = local.memory
  security_group_id          = alicloud_security_group.this.id
  auto_create_eip            = true
  eip_bandwidth              = "100"
  ingress_bandwidth          = "100"
  egress_bandwidth           = "100"

  force_delete         = true
  active               = true
  container_group_name = "${local.project_name}-${local.service_name}-${terraform.workspace}-cg"
  containers {
    #image             = "hiseven-registry.ap-southeast-1.cr.aliyuncs.com/${local.project_name}/${local.service_name}:${var.image_tag}"
    image             = "hello-world:${var.image_tag}"
    name              = "${local.project_name}-${local.service_name}-${terraform.workspace}"
    cpu               = local.cpu
    memory            = local.memory
    image_pull_policy = "IfNotPresent"

    ports {
      port     = local.port
      protocol = "TCP"
    }
    environment_vars {
      key   = "APP_ENV"
      value = var.app_env
    }

    liveness_probe_failure_threshold     = 2
    liveness_probe_initial_delay_seconds = 0
    liveness_probe_period_seconds        = 30
    liveness_probe_success_threshold     = 1
    liveness_probe_timeout_seconds       = 2
    liveness_probe_http_get_path         = "/health-check/liveness"
    liveness_probe_http_get_port         = 3000
    liveness_probe_http_get_scheme       = "HTTP"

    readiness_probe_failure_threshold = 2
    readiness_probe_period_seconds    = 30
    readiness_probe_success_threshold = 1
    readiness_probe_timeout_seconds   = 2
  }

  tags = local.tags
}

resource "alicloud_ess_scaling_rule" "this" {
  scaling_group_id  = alicloud_ess_scaling_group.this.id
  scaling_rule_type = "TargetTrackingScalingRule"
  metric_name       = "EciPodCpuUtilization"
  target_value      = 70
}

#####################
## ALB Server Group
#####################
resource "alicloud_alb_server_group" "this" {
  server_group_name = "${local.project_name}-${local.service_name}-${terraform.workspace}-alb-server-group"
  server_group_type = "Instance"
  vpc_id            = local.vpc_id
  health_check_config {
    health_check_enabled = "false"
  }
  sticky_session_config {
    sticky_session_enabled = false
  }
  lifecycle {
    ignore_changes = [servers]
  }

  tags = local.tags
}

resource "alicloud_ess_alb_server_group_attachment" "this" {
  scaling_group_id    = alicloud_ess_eci_scaling_configuration.this.scaling_group_id
  alb_server_group_id = alicloud_alb_server_group.this.id
  port                = 3000
  weight              = 100
  force_attach        = true
}

resource "random_integer" "priority" {
  min = 1000
  max = 5000
  keepers = {
    # Generate a new integer each time we switch to a new listener ARN
    listener_id = terraform.workspace == "production" ? local.production_listener_id : local.staging_listener_id
  }
}

resource "alicloud_alb_rule" "this" {
  rule_name   = "${local.project_name}-${local.service_name}-${terraform.workspace}-alb-rule"
  listener_id = random_integer.priority.keepers.listener_id
  priority    = random_integer.priority.result
  rule_conditions {
    host_config {
      values = ["${local.project_name}-${local.service_name}${local.domain_suffix}.hiseven.com"]
    }
    type = "Host"
  }
  rule_conditions {
    path_config {
      values = ["/*"]
    }
    type = "Path"
  }
  rule_actions {
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.this.id
      }
    }
    order = "9"
    type  = "ForwardGroup"
  }
}