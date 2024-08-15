output "redis_instance_id" {
  description = "This redis instance name."
  value       = module.redis.this_redis_instance_id
}

output "redis_instance_name" {
  description = "This redis instance name."
  value       = module.redis.this_redis_instance_name
}

output "redis_instance_class" {
  description = "This redis instance class."
  value       = module.redis.this_redis_instance_class
}

output "redis_instance_availability_zone" {
  description = "The availability zone in which redis instance."
  value       = module.redis.this_redis_instance_availability_zone
}

output "redis_instance_charge_type" {
  description = "This redis instance instance charge type."
  value       = module.redis.this_redis_instance_charge_type
}

output "redis_instance_type" {
  description = "This redis instance type."
  value       = module.redis.this_redis_instance_type
}

output "redis_password" {
  description = "The master password"
  value       = random_password.password.result
  sensitive   = true
}