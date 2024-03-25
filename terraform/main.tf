# Terraform 0.13+ uses the Terraform Registry:

terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

# Configure the Datadog provider
provider "datadog" {
  api_url = "https://api.us5.datadoghq.com/"

  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

