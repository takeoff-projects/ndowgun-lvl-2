data "docker_registry_image" "app" {
  name = format("gcr.io/%s/%s:%s", var.app_project, var.app_name, var.app_version)
}

data "google_container_registry_image" "app" {
  name    = var.app_name
  project = var.app_project
  digest  = data.docker_registry_image.app.sha256_digest
}

resource "google_project_service" "crm" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloud_run_service" "app" {
  depends_on = [
    google_project_service.run
  ]

  name     = var.app_name
  location = var.gcp_region

  template {
    spec {
      containers {
        image = format("gcr.io/%s/%s@%s", var.app_project, var.app_name, data.google_container_registry_image.app.digest)
        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = var.app_project
        }
      }
    }
  }
}

data "google_iam_policy" "all_users_policy" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "all_users_iam_policy" {
  location    = google_cloud_run_service.app.location
  service     = google_cloud_run_service.app.name
  policy_data = data.google_iam_policy.all_users_policy.policy_data
}

# Create a service account
resource "google_service_account" "tf_gen_sa" {
  account_id   = "tf-gen-sa"
  display_name = "Terraform generated SA"
  depends_on = [
    google_project_service.iam
  ]
}

resource "google_service_account_key" "tf_gen_sa_key" {
  service_account_id = google_service_account.tf_gen_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Set permissions
resource "google_project_iam_binding" "service_permissions" {
  for_each = toset([
    "run.admin",
    "datastore.owner",
    "appengine.appAdmin",
  ])

  role       = "roles/${each.key}"
  members    = ["serviceAccount:${google_service_account.tf_gen_sa.email}"]
  depends_on = [google_service_account.tf_gen_sa, google_project_service.crm]
}