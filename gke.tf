provider "google" {
  project = "cloud-infra-project-1-452021"  # Replace with your GCP project ID
  region  = "us-central1"
}

resource "google_container_cluster" "jenkins_sonarqube" {
  name     = "jenkins-sonarqube-cluster"
  location = "us-central1"
  remove_default_node_pool = false
  initial_node_count = 1
  deletion_protection = false 
}

resource "google_container_node_pool" "primary" {
  name       = "jenkins-sonarqube-node-pool"
  cluster    = google_container_cluster.jenkins_sonarqube.name
  location   = "us-central1"
  node_count = 2

  node_config {
    machine_type = "e2-medium"
  }
}
