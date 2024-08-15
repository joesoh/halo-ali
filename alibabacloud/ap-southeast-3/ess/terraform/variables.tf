variable "image_tag" {
  description = "The Docker image tag."
  type        = string
}

#alicloud_eci_container_group
variable "cpu" {
  description = "The amount of CPU resources allocated to the container group."
  type        = number
  default     = 0.5
}

variable "memory" {
  description = "The amount of memory resources allocated to the container group."
  type        = number
  default     = 1.0
}

variable "restart_policy" {
  description = "The restart policy of the container group. Default to Always."
  type        = string
  default     = "Always"
}

variable "container_working_dir" {
  description = "The working directory of the container."
  type        = string
  default     = "/tmp/workdir"
}

variable "container_image_pull_policy" {
  description = "The restart policy of the image."
  type        = string
  default     = "IfNotPresent"
}

variable "container_commands" {
  description = "The commands run by the init container."
  type        = list(string)
  default     = ["/bin/sh", "-c", "sleep 9999"]
}

variable "volume_mounts" {
  description = "The structure of volumeMounts."
  type        = map(string)
  default = {
    mount_path = "/tmp/mnt"
    read_only  = false
    name       = "tmp"
  }
}

variable "environment_vars" {
  description = "The structure of environmentVars."
  type        = map(string)
  default = {
    key   = "key"
    value = "abc123"
  }
}

variable "init_container_name" {
  description = "The name of the init container."
  type        = string
  default     = "init"
}

variable "init_container_image" {
  description = "The image of the container."
  type        = string
  default     = "hiseven-registry-vpc.ap-southeast-1.cr.aliyuncs.com/tgbot/busybox:latest"
}

variable "init_container_image_pull_policy" {
  description = "The restart policy of the image."
  type        = string
  default     = "IfNotPresent"
}

variable "init_container_commands" {
  description = "The commands run by the init container."
  type        = list(string)
  default     = ["echo"]
}

variable "init_container_args" {
  description = "The arguments passed to the commands."
  type        = list(string)
  default     = ["hello initcontainer"]
}

variable "volumes" {
  description = "The list of volumes."
  type        = map(string)
  default = {
    name = "empty1"
    type = "EmptyDirVolume"
  }
}

variable "app_env" {
  description = "The App Env."
  default     = "stg"
  type        = string
}