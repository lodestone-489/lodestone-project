# Datadog auth vars
variable "datadog_api_key" {
  description = "The Datadog API key"
  type = string
}

variable "datadog_app_key" {
  description = "The Datadog application key"
  type = string
}

# CI config vars
variable "ci_provider_name" {
  description = "The provider of our CI"
  type = string
}
