
terraform {
  required_version = ">= 0.13.1"
}

provider tls {
	version = "<4.0.0"
}

module "eks" {
  source = "../../../../../_terraform_modules/xebia/terraform-aws-xebia-eks@v1.4.0"
	
  add_namespaces = var.add_namespaces
  assume_role_arn = var.assume_role_arn
  aws_lb_controller_ingress_class = var.aws_lb_controller_ingress_class
  aws_lb_controller_resources_limits_cpu = var.aws_lb_controller_resources_limits_cpu
  aws_lb_controller_resources_limits_memory = var.aws_lb_controller_resources_limits_memory
  aws_lb_controller_resources_request_cpu = var.aws_lb_controller_resources_request_cpu
  aws_lb_controller_resources_request_memory = var.aws_lb_controller_resources_request_memory
  aws_load_balancer_controller_image_repo = var.aws_load_balancer_controller_image_repo
  aws_load_balancer_controller_image_tag = var.aws_load_balancer_controller_image_tag
  cluster_autoscaler_image_repo = var.cluster_autoscaler_image_repo
  cluster_autoscaler_image_tag = var.cluster_autoscaler_image_tag
  cluster_autoscaler_resources_limits_cpu = var.cluster_autoscaler_resources_limits_cpu
  cluster_autoscaler_resources_limits_memory = var.cluster_autoscaler_resources_limits_memory
  cluster_autoscaler_resources_requests_cpu = var.cluster_autoscaler_resources_requests_cpu
  cluster_autoscaler_resources_requests_memory = var.cluster_autoscaler_resources_requests_memory
  cluster_create_endpoint_private_access_sg_rule = var.cluster_create_endpoint_private_access_sg_rule
  cluster_enabled_log_types = var.cluster_enabled_log_types
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_private_access_sg = var.cluster_endpoint_private_access_sg
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  create_opensearch_sa = var.create_opensearch_sa
  create_private_registry_secret = var.create_private_registry_secret
  create_prometheus_sa = var.create_prometheus_sa
  enableShield = var.enableShield
  enableWaf = var.enableWaf
  enableWafv2 = var.enableWafv2
  existing_system_namespaces = var.existing_system_namespaces
  existing_vpc_id = var.existing_vpc_id
  existing_vpc_subnets = var.existing_vpc_subnets
  extra_tags = var.extra_tags
  map_aws_roles = var.map_aws_roles
  map_aws_users = var.map_aws_users
  map_k8s_roles = var.map_k8s_roles
  node_groups = var.node_groups
  node_groups_defaults = var.node_groups_defaults
  node_security_group_additional_rules = var.node_security_group_additional_rules
  opensearch_write_assume_role_arn = var.opensearch_write_assume_role_arn
  prometheus_amp_assume_role_arn = var.prometheus_amp_assume_role_arn
  provider_key_arn = var.provider_key_arn
  region = var.region
  registry_password = var.registry_password
  registry_server = var.registry_server
  registry_username = var.registry_username
  required_labels = var.required_labels
}
