
output "vpc_id" {
  description = "The id of vpc."
  value       = local.vpc_id
}

output "security_group_id" {
  description = "The id of security group."
  value       = alicloud_security_group.this.id
}

output "alicloud_ess_eci_scaling_configuration_id" {
  description = "The id of eci container group."
  value       = alicloud_ess_eci_scaling_configuration.this.id
}