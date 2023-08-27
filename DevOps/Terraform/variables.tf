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
