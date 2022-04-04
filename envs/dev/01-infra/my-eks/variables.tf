variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "assume_role_arn" {
  description = "assume role in which account to create"
  type        = string
  default     = ""
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.21"
}

variable "required_labels" {
  type = object({
    project = string
  })
}

variable "node_groups" {
  type = list(object({
    name          = string
    min_capacity  = number
    max_capacity  = number
    instance_type = string
    capacity_type = string
    labels        = map(string)
  }))

  default = [{
    name          = "worker-1"
    min_capacity  = 3
    max_capacity  = 9
    instance_type = "m5.medium"
    capacity_type = "ON_DEMAND"
    labels        = { type = "memory-intensive" }
  }]

  validation {
    condition     = alltrue([for group in var.node_groups : group.min_capacity >= 2])
    error_message = "Minimum capacity of a node group must be greater than two."
  }
}

variable "existing_vpc" {
  type = object({
    vpc_id  = string
    subnets = list(string)
  })

  default = {
    vpc_id  = "vpc_id"
    subnets = ["subnet_id1", "subnet_id2"]
  }
}

variable "map_aws_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []

  # default = [
  #   {
  #     rolearn  = "arn:aws:iam::66666666666:role/role1"
  #     username = "role1"
  #     groups   = ["system:masters"]
  #   },
  # ]
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

variable "namespaces" {
  type    = list(string)
  default = []
}
variable "node_groups_defaults" {
  type    = any
  default = {}
}
variable "cluster_endpoint_private_access" {
  type    = bool
  default = false
}

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


variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}
variable "cluster_enabled_log_types" {
  type    = list(string)
  default = []
}
variable "cluster_create_endpoint_private_access_sg_rule" {
  description = "Whether to create security group rules for the access to the Amazon EKS private API server endpoint. When is `true`, `cluster_endpoint_private_access_cidrs` must be setted."
  type        = bool
  default     = false
}
variable "cluster_endpoint_private_access_sg" {
  description = "List of security group IDs which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true`."
  type        = list(string)
  default     = null
}
# Cluster Autoscaler
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
  default     = "300Mi"
}
variable "cluster_autoscaler_resources_limits_cpu" {
  description = "Cluster Autoscaler CPU limits"
  type        = string
  default     = "100m"
}
# AWS Load Balancer Controller
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
variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Add extra tags to your resource"
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
variable "provider_key_arn" {
  description = "KMS key arn to enable encryption of secrets in EKS"
  type        = string
  default     = ""
}
