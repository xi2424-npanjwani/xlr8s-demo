# PROVIDER CONFIGURATION

variable "region" {
  type        = string
  default     = "ap-south-1"
  description = "provider region, where resources will be created"
}
variable "assume_role_arn" {
  description = "assume role in which account to create"
  type        = string
  default     = ""
}
variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Add extra tags to your resource"
}

# CLUSTER CONFIGURATION

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}
variable "cluster_version" {
  type        = string
  default     = "1.21"
  description = "Kubernetes version to use for the EKS cluster"
}
variable "required_labels" {
  type = object({
    project = string
  })
  description = "tags to use for the resources being created"
}
variable "existing_vpc_id" {
  type        = string
  description = "vpc id where EKS cluster will be provisioned."
  default     = ""
}
variable "existing_vpc_subnets" {
  type        = list(string)
  description = "subnets where EKS cluster will be provisioned."
  default     = [""]
}
variable "provider_key_arn" {
  description = "KMS key arn to enable encryption of secrets in EKS. A key, with rotation enabled, will be generated in case no arn is provided"
  type        = string
  default     = ""
}

# CLUSTER ENDPOINT CONFIGURATION

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}
variable "cluster_endpoint_private_access_sg" {
  description = "List of security group IDs which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true`."
  type        = list(string)
  default     = []
}
variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

# Cluster Access Control

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}
variable "map_aws_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "map_aws_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

# CLUSTER LOGGING CONFIGURATION

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

# NODE GROUP CONFIGURATION

variable "node_groups_defaults" {
  description = "Map of EKS managed node group default configurations"
  type        = any
  default = {
    ami_type                   = "AL2_x86_64"
    disk_size                  = 50
    iam_role_attach_cni_policy = true
  }
}
variable "node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type = list(object({
    name           = string
    min_capacity   = number
    max_capacity   = number
    instance_types = list(string)
    capacity_type  = string
    labels         = map(string)
  }))

  default = [{
    name           = "worker-1"
    min_capacity   = 3
    max_capacity   = 9
    instance_types = ["m5.medium"]
    capacity_type  = "ON_DEMAND"
    labels         = { type = "memory-intensive" }
  }]

  validation {
    condition     = alltrue([for group in var.node_groups : group.min_capacity >= 2])
    error_message = "Minimum capacity of a node group must be greater than two."
  }
}
variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }
  }
}

# AWS LOAD BALANCER CONTROLLER CONFIGURATION

variable "aws_lb_controller_resources_request_cpu" {
  description = "AWS Load Balancer Controller CPU request"
  type        = string
  default     = "100m"
}
variable "aws_lb_controller_resources_request_memory" {
  description = "AWS Load Balancer Controller memory request"
  type        = string
  default     = "128Mi"
}
variable "aws_lb_controller_resources_limits_cpu" {
  description = "AWS Load Balancer Controller CPU limits"
  type        = string
  default     = "100m"
}
variable "aws_lb_controller_resources_limits_memory" {
  description = "AWS Load Balancer Controller memory limits"
  type        = string
  default     = "128Mi"
}
variable "aws_lb_controller_ingress_class" {
  description = "AWS Load Balancer Controller ingress class"
  type        = string
  default     = "alb"
}
variable "cluster_autoscaler_image_repo" {
  description = "Repository where cluster autoscaler container image is present"
  type        = string
  default     = "k8s.gcr.io/autoscaling/cluster-autoscaler"
}
variable "aws_load_balancer_controller_image_repo" {
  description = "Repository where aws loadbalancer controller container image is present"
  type        = string
  default     = "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon/aws-load-balancer-controller"
}
variable "aws_load_balancer_controller_image_tag" {
  description = "aws loadbalancer controller container image tag"
  type        = string
  default     = "v2.2.4"
}

# AWS LOAD BALANCER CONTROLLER SECURITY CONFIGURATION

variable "enableShield" {
  type        = bool
  default     = true
  description = "Enable Shield addon for ALB. Update to false while create private EKS cluster"
}
variable "enableWaf" {
  type        = bool
  default     = true
  description = "Enable WAF addon for ALB. Update to false while create private EKS cluster"
}
variable "enableWafv2" {
  type        = bool
  default     = true
  description = "Enable WAF V2 addon for ALB. Update to false while create private EKS cluster"
}

# CLUSTER AUTOSCALER CONFIGURATION

variable "cluster_autoscaler_image_tag" {
  description = "Cluster Autoscaler image tag that matches the Kubernetes major and minor version of your cluster"
  type        = string
  default     = "v1.21.0"
}
variable "cluster_autoscaler_resources_requests_cpu" {
  description = "Cluster Autoscaler CPU request"
  type        = string
  default     = "100m"
}
variable "cluster_autoscaler_resources_requests_memory" {
  description = "Cluster Autoscaler memory request"
  type        = string
  default     = "300Mi"
}
variable "cluster_autoscaler_resources_limits_memory" {
  description = "Cluster Autoscaler memory limits"
  type        = string
  default     = "1000Mi"
}
variable "cluster_autoscaler_resources_limits_cpu" {
  description = "Cluster Autoscaler CPU limits"
  type        = string
  default     = "400m"
}

# ADD Custom RBAC

variable "map_k8s_roles" {
  description = "Additional k8s roles to add to the cluster."
  type = list(object({
    name      = string
    group     = string
    scope     = string
    namespace = string
    labels    = map(string)
    rules = list(object({
      api_groups = list(string)
      resources  = list(string)
      verbs      = list(string)
    }))
  }))

  default = []

  validation {
    condition     = alltrue([for role in var.map_k8s_roles : role.scope == "NAMESPACE" || role.scope == "CLUSTER"])
    error_message = "Role scope must be NAMESPACE or CLUSTER."
  }
}
variable "cluster_create_endpoint_private_access_sg_rule" {
  description = "Whether to create security group rules for the access to the Amazon EKS private API server endpoint. When is `true`, `cluster_endpoint_private_access_cidrs` must be setted."
  type        = bool
  default     = false
}
variable "add_namespaces" {
  type = list(object({
    name         = string
    enable_istio = bool
  }))
  default     = [{ name = "dev", enable_istio = true }, { name = "monitoring", enable_istio = false }, { name = "logging", enable_istio = false }]
  description = "Add new namespaces to cluster to deploy apps and provide bool for istio_enable"
}
variable "existing_system_namespaces" {
  type        = list(string)
  default     = ["kube-system", "default"]
  description = "Existing namespaces where private registry secret needs to be added"
}
variable "create_private_registry_secret" {
  type        = bool
  default     = false
  description = "whether to add private docker registry secret in namespaces, true if private registry is used to pull images"
}
variable "registry_username" {
  type        = string
  description = "Private Docker registry username, should be passed as environment variable TF_VAR_registry_username"
  default     = ""
}
variable "registry_password" {
  type        = string
  sensitive   = true
  description = "Private Docker registry password, should be passed as environment variable TF_VAR_registry_password"
  default     = ""
}
variable "registry_server" {
  type        = string
  description = "Private Docker registry server url, should be passed as environment variable TF_VAR_registry_server"
  default     = ""
}

# IRSA CONFIGURATION FOR PROMETHEUS AND FLUENTBIT

variable "create_prometheus_sa" {
  type        = bool
  description = "Enable it to create a service account with IRSA configuration for aws managed prometheus service."
  default     = false
}
variable "create_opensearch_sa" {
  type        = bool
  description = "Enable it to create a service account with IRSA configuration for opensearch."
  default     = false
}
variable "prometheus_amp_assume_role_arn" {
  type        = string
  description = "Assume role arn for prometheus amp"
  default     = ""
}
variable "opensearch_write_assume_role_arn" {
  type        = string
  description = "Assume role arn for opensearch"
  default     = ""
}