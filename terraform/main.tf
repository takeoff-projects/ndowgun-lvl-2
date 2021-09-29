module "cloud_run" {
  source      = "./cloud_run"
  app_project = var.app_project
  image_name  = var.image_name
  gcp_region  = var.gcp_region
}