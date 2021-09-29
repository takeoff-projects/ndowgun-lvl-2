#define service account credentials
variable "gcp_auth_file" {
  type        = string
  description = "GCP authentication file"
}
# define GCP project name
variable "app_project" {
  type        = string
  description = "GCP project name"
}
variable "gcp_region" {
  description = "name of specific region to deploy services into, e.g. eu-west1"
  default     = "us-central1"
}
variable "api_spec_file" {
  description = "path to the api spec file"
}
