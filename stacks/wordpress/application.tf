data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

resource "kubernetes_namespace" "wordpress" {
  metadata {
    name = var.name
  }
}

resource "helm_release" "wordpress" {
  name       = var.name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "wordpress"
  version    = "6.8.1"

  create_namespace = false
  cleanup_on_fail  = true
  namespace        = var.name
  depends_on = [
    kubernetes_namespace.wordpress
  ]

  set = [
    {
      name  = "service.type"
      value = "ClusterIP"
    },
    {
      name  = "persistence.enabled"
      value = "false"
    },
    {
      name  = "wordpressAutoUpdateLevel"
      value = "minor"
    },
    {
      name  = "mariadb.enabled"
      value = "false"
    },
    {
      name  = "externalDatabase.host"
      value = module.database.cluster_endpoint
    },
    {
      name  = "externalDatabase.port"
      value = module.database.cluster_port
    },
    {
      name  = "externalDatabase.user"
      value = module.database.cluster_master_username
    },
    {
      name  = "externalDatabase.password"
      # fixme
      value = "blah"
    },
    {
      name  = "externalDatabase.database"
      value = "wordpress"
    },
  ]
}
