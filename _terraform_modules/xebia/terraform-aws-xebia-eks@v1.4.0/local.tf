locals {
  k8s_service_account_namespace                = "kube-system"
  cluster_autoscaler_service_account           = "cluster-autoscaler"
  aws_cluster_autoscaler_role_name             = "${var.cluster_name}-cluster-autoscaler"
  aws_load_balancer_controller_role_name       = "${var.cluster_name}-aws-load-balancer-controller"
  aws_load_balancer_controller_service_account = "aws-load-balancer-controller"
  map_aws_roles = [
    for r in var.map_aws_roles : {
      rolearn  = replace(r.rolearn, "/aws-reserved/sso.amazonaws.com", "")
      username = r.username
      groups   = r.groups
    }
  ]
  # Make a list of all the cluster roles
  k8s_cluster_roles = matchkeys(var.map_k8s_roles, var.map_k8s_roles[*].scope, ["CLUSTER"])
  # Make a list of all the local roles
  k8s_local_roles = matchkeys(var.map_k8s_roles, var.map_k8s_roles[*].scope, ["NAMESPACE"])
}