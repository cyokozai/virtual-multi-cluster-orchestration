locals {
  karmada_values = {
    # apiserver の公開方法
    apiserver = var.expose_karmada_apiserver ? {
      service = {
        type = "LoadBalancer"
        # annotations = { "networking.gke.io/load-balancer-type" = "External" }
      }
    } : {}

    etcd = {
      resources = {
        requests = { cpu = "200m", memory = "512Mi" }
        limits   = { cpu = "1",    memory = "1Gi" }
      }
      persistence = { enabled = true, size = "10Gi" }
    }

    controllerManager = {
      resources = {
        requests = { cpu = "200m", memory = "256Mi" }
      }
    }
    scheduler = {
      resources = {
        requests = { cpu = "200m", memory = "256Mi" }
      }
    }
  }
}

resource "helm_release" "karmada" {
  name       = "karmada"
  repository = "https://karmada-io.github.io/charts"
  chart      = "karmada"
  namespace  = "karmada-system"
  create_namespace = true

  version = var.karmada_chart_version

  values = [yamlencode(local.karmada_values)]

  depends_on = [google_container_node_pool.default]
}