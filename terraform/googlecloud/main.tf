terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }

  required_version = ">= 1.0"

  backend "local" {}
}


provider "google" {
  project = var.cluster_project_id
  region  = var.region
}


resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  project                 = var.network_project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}


resource "google_compute_subnetwork" "gke_subnet" {
  # サブネットが作成されるプロジェクトを指定
  project = var.network_project_id
  name    = "${var.cluster_name}-subnet"
  region  = var.region

  # --network=$NETWORK_PROJECT_ID に相当
  network = google_compute_network.vpc_network.self_link

  # プライマリIPレンジ
  ip_cidr_range = "10.0.0.0/24"

  # --enable-ip-alias に相当するセカンダリIPレンジ
  # Pod用のIPレンジ
  secondary_ip_range {
    range_name    = "${var.cluster_name}-pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  # Service用のIPレンジ
  secondary_ip_range {
    range_name    = "${var.cluster_name}-services"
    ip_cidr_range = "10.2.0.0/20"
  }

  private_ip_google_access = true
}


resource "google_container_cluster" "primary" {
  # --fleet-project $FLEET_PROJECT_ID に相当
  # GKEクラスタが作成されるプロジェクトとは別に、Fleetがホストされるプロジェクトを指定
  project = var.cluster_project_id

  # クラスタ名
  name = var.cluster_name

  # --zone=$ZONE に相当
  location = var.zone

  # 既存のノードを削除してから新しいノードを作成する設定
  # gcloudコマンドのデフォルトの挙動に合わせます
  remove_default_node_pool = true
  initial_node_count       = 1

  # --network と --subnetwork に相当
  network    = google_compute_subnetwork.gke_subnet.network
  subnetwork = google_compute_subnetwork.gke_subnet.self_link

  # --enable-ip-alias に相当
  # サブネットで定義したセカンダリIPレンジ名を指定します
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.gke_subnet.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.gke_subnet.secondary_ip_range[1].range_name
  }

  # --labels=intern-inoue に相当
  resource_labels = {
    intern-inoue = "true" # ラベルのキーと値を設定
  }

  # --fleet-project $FLEET_PROJECT_ID に相当
  fleet {
    project = "${var.fleet_project_id}"
  }
}


resource "google_container_node_pool" "primary_nodes" {
  name       = "default-pool"
  project    = var.cluster_project_id
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 3 # --num-nodes 3 に相当

  node_config {
    # GKEが推奨するCos_containerdイメージタイプを使用
    image_type = "COS_CONTAINERD"
    machine_type = "e2-medium" # 必要に応じて変更してください

    # ノードプールにもラベルを付与する場合
    labels = {
      intern-inoue = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}