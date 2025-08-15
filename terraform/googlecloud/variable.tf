variable "cluster_project_id" {
  description = "クラスタを作成するプロジェクトID"
}

variable "fleet_project_id" {
  description = "Fleet（Anthos）プロジェクトID"
}

variable "network_project_id" {
  description = "使用する VPC ネットワークのプロジェクトID"
}

variable "zone" {
  description = "クラスタを作成するゾーン"
}

variable "region" {
  description = "リージョン（必要な場合）"
}

variable "cluster_name" {
  description = "GKEクラスタの名前"
}