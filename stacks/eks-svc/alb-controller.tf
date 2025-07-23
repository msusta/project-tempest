# IAM
module "role_alb_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.59.0"

  role_name_prefix = "${var.cluster_name}-alb-controller"

  oidc_providers = {
    eks = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  attach_load_balancer_controller_policy = true
}

# SA
resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/name"= "aws-load-balancer-controller"
        "app.kubernetes.io/component"= "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.role_alb_controller.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.alb_controller
  ]

  set = [
    {
      name  = "region"
      value = split(":", data.aws_eks_cluster.this.arn)[3]
    },{
      name  = "vpcId"
      value = var.vpc_id
    },{
      name  = "serviceAccount.create"
      value = "false"
    },{
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },{
      name  = "clusterName"
      value = var.cluster_name
    }
  ]
}
