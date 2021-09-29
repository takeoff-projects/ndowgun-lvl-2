locals {
  api_config_id_prefix     = "api"
  api_gateway_container_id = "api-gw"
  gateway_id               = "gw"
}

resource "google_project_service" "api" {
  project            = var.app_project
  service            = "apigateway.googleapis.com"
  disable_on_destroy = false
}

resource "google_api_gateway_api" "api_gw" {
  provider     = google-beta
  api_id       = local.api_gateway_container_id
  display_name = "The API Gateway"
  depends_on   = [google_project_service.api]
}

resource "google_api_gateway_api_config" "api_cfg" {
  provider             = google-beta
  api                  = google_api_gateway_api.api_gw.api_id
  api_config_id_prefix = local.api_config_id_prefix
  display_name         = "The Config"

  openapi_documents {
    document {
      path     = "api-spec.yaml"
      # todo: push this file to storage when we PUBLISH,
      # and then use a variable here to point at the file location
      # in the cloud.
      contents = filebase64(abspath(var.api_spec_file))
    }
  }
}

resource "google_api_gateway_gateway" "gw" {
  project  = var.app_project
  provider = google-beta
  region   = var.gcp_region

  api_config = google_api_gateway_api_config.api_cfg.id

  gateway_id   = local.gateway_id
  display_name = "The Gateway"

  depends_on = [google_api_gateway_api_config.api_cfg]
}
