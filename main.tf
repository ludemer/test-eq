data "google_project" "project-name" {
  project_id = var.gcp_project
}
resource "google_compute_network" "vpc-test" {
  name = "vpc-test"
  auto_create_subnetworks = false
  project = data.google_project.project-name.project_id
}

resource "google_compute_subnetwork" "subnet-test" {
  name = "subnet-test"
  network = google_compute_network.vpc-test.name
  ip_cidr_range = "10.1.0.0/22"
  region =  var.gcp_region 
  private_ip_google_access = true
  project = var.gcp_project
  #project = data.google_project.project-name.project_id

}
#habilitar puerto

resource "google_compute_firewall" "allow-access" {
  name = "allow-access"
  project = var.gcp_project
  network = google_compute_network.vpc-test.name
  allow {
    protocol = "tcp"
  }
  source_ranges = ["35.235.240.0/20"]
  priority = 500
}

resource "google_compute_firewall" "allow-ssh-http" {
  name = "allow-ssh-http"
  project = var.gcp_project
  network = google_compute_network.vpc-test.name
  allow {
    protocol = "tcp"
        ports    = ["80", "22", "8080", "1000-2000"]

  }
  source_tags = ["test-eq"]
}
#/*###########cluester gke###############################################
resource "google_container_cluster" "primary" {
  provider                 = google-beta
  name                     = var.name_k8s
  project = var.gcp_project
  remove_default_node_pool = true
  initial_node_count       = 3
  
  vertical_pod_autoscaling {
    enabled = "true"
  }
  description              = "Cluster test Eq"
  network                  =  google_compute_network.vpc-test.id
  subnetwork               =  google_compute_subnetwork.subnet-test.id 
  enable_l4_ilb_subsetting = "true"
  depends_on = [ google_compute_network.vpc-test ]

  private_cluster_config {
    enable_private_endpoint = "false"
    enable_private_nodes    = "true"
    master_ipv4_cidr_block  = "172.31.128.32/28"
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.32.0.0/14"
    services_ipv4_cidr_block = "10.0.0.0/20"
  }
  resource_labels = {
    "environment" = "test"
    "project"     =  var.gcp_project
}
   
}

 resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "test-pool"
  cluster    = google_container_cluster.primary.id
  node_count = 3
  project = var.gcp_project
  autoscaling {
    min_node_count = "1"
    max_node_count = "2"
  }

  node_config {
    preemptible  = true
    machine_type = "e2-standard-2"
    disk_type    = "pd-standard"
    disk_size_gb = "20"

    service_account = "sa-access-resosurce@test-eq-393918.iam.gserviceaccount.com"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
} 
##############

################Data base############
resource "google_sql_database_instance" "postgresql-test" {
  name = "postgresql-test"
  database_version = "POSTGRES_15"
  deletion_protection = false
  project = var.gcp_project 
  
  settings {
    tier = "db-f1-micro"
  }

}
resource "google_sql_database" "database-test" {
  name     = "test"
  instance = google_sql_database_instance.postgresql-test.name
  project = var.gcp_project 
}
resource "google_sql_user" "user" {
  name = "test"
  password = "test1234"
  instance = google_sql_database_instance.postgresql-test.name 
  project = var.gcp_project 
}

#/*######################         CR      ####################
resource "google_artifact_registry_repository" "my-test" {
  location      = var.gcp_region
  repository_id = "my-test"
  description   = "repositorio test  docker"
  format        = "DOCKER"
  project = var.gcp_project #"test-eq"
}
#*/
################   bastion   #################
resource "google_compute_instance" "test-bastion" {
  name = "test-bastion"
  zone = "us-central1-a" # var.gcp_zone
  project = var.gcp_project
  machine_type = "n2-standard-2"
  allow_stopping_for_update = true
  network_interface {
    network = "vpc-test"
    subnetwork = "projects/test-eq-393918/regions/us-central1/subnetworks/subnet-test" #google_compute_subnetwork.subnet-test.name #"subnet-test"
    subnetwork_project = google_compute_network.vpc-test.self_link
     access_config {
      network_tier = "PREMIUM"
    }


  }

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230724"
      size  = 10
      type  = "pd-standard"
      
    }
    auto_delete = false
  }

  labels = {
    "env" = "test"
  }

   scheduling {
    preemptible = false
    automatic_restart = false
  }
    
    #metadata_startup_script = "echo hi > /test.txt" 
    metadata_startup_script = "${file("init.sh")}"
  
  service_account {
    email = "sa-access-resosurce@test-eq-393918.iam.gserviceaccount.com"
    #email = " 204318118528-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

}
#############            DNS     #############
resource "google_dns_managed_zone" "test-dns" {
  name        = "dns"
  dns_name    = "test.dns.com."
  description = "DNS para test-eq"
  project = var.gcp_project
  #project = "test-eq"
  labels = {
    env = "test"
  }
}
data "google_dns_managed_zone" "test-dns" {
  name = google_dns_managed_zone.test-dns.name 
  project = var.gcp_project
  #project = "test-eq"
}

resource "google_dns_record_set" "a" {
  #name = "eq."
  name =  "eq.${google_dns_managed_zone.test-dns.dns_name}"  
  project = var.gcp_project
  managed_zone = google_dns_managed_zone.test-dns.name
  type         = "A"
  ttl          = 300

  rrdatas =  ["10.0.8.20"]
}

resource "google_compute_address" "internal-ip" {
    name = "eq" 
    subnetwork = google_compute_subnetwork.subnet-test.name 
    address_type = "INTERNAL"
    #region = var.gcp_region
    region = "us-central1"
    description = "Ip internal to service ingress" 
    #network_tier = "PREMIUM"
    project = var.gcp_project
    }
