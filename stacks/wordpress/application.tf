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
  #version    = "6.8.1"

  create_namespace = false
  cleanup_on_fail  = true
  namespace        = var.name
  depends_on = [
    kubernetes_namespace.wordpress
  ]

  set = [
    {
      name  = "image.debug"
      value = "true"
    },
    {
      name  = "service.type"
      value = "ClusterIP"
    },
    {
      name  = "ingress.enabled"
      value = "true"
    },
    {
      name  = "ingress.hostname"
      value = var.domain
    },
    {
      name  = "ingress.path"
      value = "/*"
    },
    {
      name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
      value = "alb"
    },
    {
      name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
      value = "ip"
    },
    {
      name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/load-balancer-name"
      value = "${var.name}"
    },
    {
      name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
      value = "internet-facing"
    },
    {
      name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/certificate-arn"
      value = var.acm_certificate_arn
    },
    {
      name  = "persistence.enabled"
      value = "false"
    },
    {
      name  = "autoscaling.enabled"
      value = "true"
    },
    {
      name  = "autoscaling.minReplicas"
      value = "2"
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
      value = random_password.db_password.result
    },
    {
      name  = "externalDatabase.database"
      value = "wordpress"
    },
  ]
}
