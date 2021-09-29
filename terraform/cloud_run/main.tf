
data "google_container_registry_image" "app" {
  name = var.image_name
}

resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloud_run_service" "app" {
  depends_on = [
    google_project_service.run
  ]

  name     = "events-app"
  location = var.gcp_region

  template {
    spec {
      containers {
        image = data.google_container_registry_image.app.image_url
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