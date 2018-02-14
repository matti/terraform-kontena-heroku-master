variable "heroku_email" {
  default = ""
}

variable "heroku_api_key" {
  default = ""
}

variable "heroku_organization" {
  default = ""
}

variable "region" {
  default = "us"
}

variable "app_name" {}

variable "kontena_master_version" {
  default = "latest"
}

variable "kontena_master_name" {
  default = "heroku-master"
}

variable "initial_admin_code" {
  default = ""
}

variable "container_logs_capped_size" {
  default = 10
}

variable "container_stats_capped_size" {
  default = 10
}

variable "events_logs_capped_size" {
  default = 1
}

variable "max_threads" {
  default = 4
}

variable "web_concurrency" {
  default = 1
}

variable "mongo_addon_plan" {
  default = "mongolab:sandbox"
}
