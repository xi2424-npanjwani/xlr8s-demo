module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 17.1.0"

  # Basic cluster information
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  tags            = var.required_labels

  # Need to add support to make the VPC creation optional. In that case the VPC id and subnet
  # ids will be provided by the operator.
  vpc_id  = var.existing_vpc.vpc_id
  subnets = var.existing_vpc.subnets

  # We enable IRSA (IAM Roles for Service Accounts) to follow the best practices when it comes
  # to accessing AWS resources from within EKS. This is required to setup the cluster autoscaler.
  enable_irsa = true
  # for enabling secret encryption
  cluster_encryption_config = [{
    provider_key_arn = var.provider_key_arn
    resources        = ["secrets"]
  }]
  # EKS private API server endpoint 
  cluster_endpoint_private_access                = var.cluster_endpoint_private_access
  cluster_create_endpoint_private_access_sg_rule = var.cluster_create_endpoint_private_access_sg_rule
  # cluster_endpoint_private_access_cidrs           = var.cluster_endpoint_private_access_cidrs
  cluster_endpoint_private_access_sg = var.cluster_endpoint_private_access_sg
  # EKS public API server endpoint
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  # cluster logging
  cluster_enabled_log_types = var.cluster_enabled_log_types
  # We will be using managed node groups in our cluster. This automates the provisioning and
  # lifecylce management of the worker nodes. Managed node groups auto inject the necessary tags
  # required for cluster autoscaler so we don't have to.
  # More details can be found here: https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html
  node_groups_defaults = var.node_groups_defaults
  node_groups = {
    for group in var.node_groups : group.name => {
      desired_capacity = group.min_capacity
      max_capacity     = group.max_capacity
      min_capacity     = group.min_capacity

      instance_types = [group.instance_type]
      capacity_type  = group.capacity_type
      k8s_labels     = merge(var.required_labels, group.labels)
    }
  }
  map_roles = local.map_aws_roles
  map_users = var.map_aws_users
}
