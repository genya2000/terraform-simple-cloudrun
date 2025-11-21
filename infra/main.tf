terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "app" {
  name     = "terraform-simple-cloudrun"
  location = var.region

  template {
    spec {
      containers {
        image = var.image
        resources {
          limits = {
            memory = "256Mi"
            cpu    = "1"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "public" {
  project  = var.project_id
  location = var.region
  service  = google_cloud_run_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# output "cloud_run_url" {
#   value = google_cloud_run_service.app.status[0].url
# }
