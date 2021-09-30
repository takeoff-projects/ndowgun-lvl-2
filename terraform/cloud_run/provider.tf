terraform {
  required_version = ">= 0.14"

  required_providers {
    # Cloud Run support was added on 3.3.0
    google = ">= 3.3"
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "google" {
  project     = var.app_project
  credentials = file(var.gcp_auth_file)
  region      = var.gcp_region
}

provider "google-beta" {
  project = var.app_project
  region  = var.gcp_region
}

provider "docker" {
  registry_auth {
    address     = "gcr.io"
    config_file = pathexpand("~/.docker/config.json")
  }
}