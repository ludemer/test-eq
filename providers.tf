terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.75.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}
provider "google" {
  # conexion terra y gcp
  project = "test-eq"
  region = "us-central1"
  zone = "us-central1-a"
  #credentials = "${file("${var.path}/sa.json")}" 
  credentials = "sa.json"
}

provider "google-beta" {
  # conexion terra y gcp
  project = "test-eq"
  region = "us-central1"
  zone = "us-central1-a"
  #credentials = "${file("${var.path}/sa.json")}" 
  credentials = "sa.json"
}