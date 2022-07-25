output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

# output "aws_auth_configmap_yaml" {
#   description = "A kubernetes configuration to authenticate to this EKS cluster."
#   value       = module.eks.aws_auth_configmap_yaml
# }

output "region" {
  description = "AWS region."
  value       = var.region
}

output "node_groups" {
  description = "Outputs from node groups"
  value       = module.eks.eks_managed_node_groups
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}