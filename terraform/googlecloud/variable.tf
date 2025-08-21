variable "env" {
  description = "環境"
  type        = string
  default     = "develop"
}

variable "fleet_project_id" {
  description = "Fleet（Anthos）プロジェクトID"
  type        = string
  default     = ""
}

variable "cluster_project_id" {
  description = "クラスタを作成するプロジェクトID"
  type        = string
  default     = ""
}

variable "network_project_id" {
  description = "使用する VPC ネットワークのプロジェクトID"
  type        = string
  default     = ""
}

variable "machine_type" {
  description = "ノードのマシンタイプ"
  type        = string
  default     = "e2-standard-4"
  
}

variable "zone" {
  description = "クラスタを作成するゾーン"
  type        = string
  default     = "asia-northeast1-a"
}

variable "region" {
  description = "リージョン（必要な場合）"
  type        = string
  default     = "asia-northeast1"
}

variable "cluster_name" {
  description = "GKEクラスタの名前"
  type        = string
  default     = "karmada-test"
}

variable "network_name" {
  description = "VPC ネットワークの名前"
  type        = string
  default     = "karmada-test"
}

variable "karmada_chart_version" {
  description = "Karmada Helm Chart のバージョン"
  type        = string
  default     = null
}

variable "expose_karmada_apiserver" {
  description = "Karmada API Server を外部に公開するか"
  type        = bool
  default     = true
}