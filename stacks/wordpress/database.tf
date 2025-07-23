module "database" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 9.15.0"

  name              = var.name
  engine            = "aurora-mysql"
  engine_mode       = "provisioned"
  engine_version    = "8.0"
  storage_encrypted = true
  master_username   = "root"
  database_name     = "wordpress"

  manage_master_user_password = false
  master_password             = random_password.db_password.result

  backup_retention_period = 14

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.database_subnet_group_name
  security_group_rules = {
    #eks_ingress = {
    #  source_security_group_id = var.eks_node_security_group_id
    #}
    # remove after testing
    vpc_ingress = {
      cidr_blocks = var.vpc_private_subnets_cidr_blocks
    }
  }

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  serverlessv2_scaling_configuration = {
    min_capacity = 0
    max_capacity = 4
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
    two = {}
  }
}

# consider ephemeral for TF >1.10
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+"
}
