# EFS vol
module "efs" {
  source = "terraform-aws-modules/efs/aws"

  name = var.cluster_name

  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }

  # File system policy
  #attach_policy                      = true
  #bypass_policy_lockout_safety_check = false
  #policy_statements = [
  #  {
  #    sid     = "Example"
  #    actions = ["elasticfilesystem:ClientMount"]
  #    principals = [
  #      {
  #        type        = "AWS"
  #        identifiers = ["arn:aws:iam::111122223333:role/EfsReadOnly"]
  #      }
  #    ]
  #  }
  #]

  # Mount targets / security group
  #mount_targets = {
  #  "eu-west-1a" = {
  #    subnet_id = "subnet-abcde012"
  #  }
  #  "eu-west-1b" = {
  #    subnet_id = "subnet-bcde012a"
  #  }
  #  "eu-west-1c" = {
  #    subnet_id = "subnet-fghi345a"
  #  }
  #}
  security_group_vpc_id = var.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provided for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = var.vpc_private_subnets_cidr_blocks
    }
  }

  # Access point(s)
  #access_points = {
  #  posix_example = {
  #    name = "posix-example"
  #    posix_user = {
  #      gid            = 1001
  #      uid            = 1001
  #      secondary_gids = [1002]
  #    }

  #    tags = {
  #      Additionl = "yes"
  #    }
  #  }
  #  root_example = {
  #    root_directory = {
  #      path = "/example"
  #      creation_info = {
  #        owner_gid   = 1001
  #        owner_uid   = 1001
  #        permissions = "755"
  #      }
  #    }
  #  }
  #}
}

# EFS SC
resource "kubernetes_storage_class" "efs" {
  metadata {
    name = "efs"
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = module.efs.id
    #subPathPattern = "${.PVC.namespace}/${.PVC.name}"
  }
}

# IAM
module "role_efs_csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.59.0"

  role_name_prefix = "${var.cluster_name}-efs-csi"

  oidc_providers = {
    eks = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  attach_efs_csi_policy = true
}

## SA
#resource "kubernetes_service_account" "efs_csi" {
#  metadata {
#    name = "aws-load-balancer-controller"
#    namespace = "kube-system"
#    labels = {
#        "app.kubernetes.io/name"= "aws-load-balancer-controller"
#        "app.kubernetes.io/component"= "controller"
#    }
#    annotations = {
#      "eks.amazonaws.com/role-arn" = module.role_alb_controller.iam_role_arn
#      "eks.amazonaws.com/sts-regional-endpoints" = "true"
#    }
#  }
#}
#
## Addon
#resource "aws_eks_addon" "efs_csi" {
#  cluster_name = var.cluster_name
#  addon_name   = "aws-efs-csi-driver"
#
#  preserve = true
#  resolve_conflicts_on_create = "OVERWRITE"
#  resolve_conflicts_on_update = "OVERWRITE"
#  service_account_role_arn    = module.role_efs_csi.iam_role_arn
#
#  #timeouts {
#  #  create = try(each.value.timeouts.create, var.cluster_addons_timeouts.create, null)
#  #  update = try(each.value.timeouts.update, var.cluster_addons_timeouts.update, null)
#  #  delete = try(each.value.timeouts.delete, var.cluster_addons_timeouts.delete, null)
#  #}
#}
