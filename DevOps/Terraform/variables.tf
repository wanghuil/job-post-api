variable "region" {
  type    = string
  default = "us-east-1"
}

variable "dynamodb" {
  type    = string
  default = "terraform-state-lock-dynamodb-land-tasker-backend"
}

variable "acm_arn" {
  type    = string
  default = "arn:aws:acm:us-east-1:498265900521:certificate/6361273a-117e-4009-9186-eb47da959150"
}

variable "container_port"{
  type    = number
  default = 5000
}

variable "execution_role_arn" {
  type    = string
  default = "arn:aws:iam::498265900521:role/ecsTaskExecutionRole"
}

variable "task_memory" {
  description = "Amount (in MiB) of memory used by the task."
  default     = 3072
  type        = number
}

variable "task_cpu" {
  description = "Number of CPU units used by the task."
  default     = 1024
  type        = number
}

variable "task_operating_system_family" {
  description = "OS family required by the task."
  default     = "LINUX"
  type        = string
}

variable "task_cpu_architecture" {
  description = "CPU architecture required by the task."
  default     = "X86_64"
  type        = string

  validation {
    condition     = contains(["X86_64", "ARM64"], var.task_cpu_architecture)
    error_message = "Value must be `X86_64` or `ARM64`."
  }
}

variable "image" {
  description = "ecr image"
  default     = "498265900521.dkr.ecr.us-east-1.amazonaws.com/job-post-api-1:latest"
  type        = string
}

variable "desired_count" {
  default     = 1
  description = "Number of desired Fargate tasks."
  type        = number
}

variable "enable_execute_command" {
  default     = true
  description = "Allow execution commands on containers."
  type        = bool
}

variable "deployment_maximum_percent" {
  default     = 200
  description = "Maximum deployment percent. Usually double minimum to allow rolling deployment."
  type        = number
}

variable "deployment_minimum_healthy_percent" {
  default     = 100
  description = "Minimum deployment percent. Usually set to 100 to ensure at least one task."
  type        = number
}

variable "container_name" {
  default     = "land-tasker-container"
  description = "Name of container to create task definition with."
  type        = string
}

variable "enable_awslogs" {
  default     = "true"
  description = "Allow aws cloudwatch logs."
  type        = string
}

variable "enable_containerInsights" {
  default     = "enabled"
  description = "Allow containerInsights/cloudwatch logs."
  type        = string
}


variable "ecs_launch_type" {
  default     = "FARGATE"
  type        = string
}

variable "protocol" {
  default     = "tcp"
  type        = string
}

variable "cidr_blocks_anywhere" {
  default     = "0.0.0.0/0"
  type        = string
}
