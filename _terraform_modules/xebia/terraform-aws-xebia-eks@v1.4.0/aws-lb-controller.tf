resource "helm_release" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.2.6"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "region"
    value = var.region
  }
  set {
    name  = "ingressClass"
    value = var.aws_lb_controller_ingress_class
  }
  set {
    name  = "vpcId"
    value = var.existing_vpc_id
  }
  set {
    name  = "enableShield"
    value = var.enableShield
  }
  set {
    name  = "enableWaf"
    value = var.enableWaf
  }
  set {
    name  = "enableWafv2"
    value = var.enableWafv2
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "image.repository"
    value = var.aws_load_balancer_controller_image_repo
  }
  set {
    name  = "image.tag"
    value = var.aws_load_balancer_controller_image_tag
  }
  set {
    name  = "serviceAccount.name"
    value = local.aws_load_balancer_controller_service_account
  }
  set {
    name  = "resources.requests.cpu"
    value = var.aws_lb_controller_resources_request_cpu
  }
  set {
    name  = "resources.requests.memory"
    value = var.aws_lb_controller_resources_request_memory
  }

  set {
    name  = "resources.limits.cpu"
    value = var.aws_lb_controller_resources_limits_cpu
  }

  set {
    name  = "resources.limits.memory"
    value = var.aws_lb_controller_resources_limits_memory
  }

  set {
    name  = "imagePullSecrets[0].name"
    value = var.create_private_registry_secret == true ? "private-registry-secret" : ""
  }
}

data "template_file" "aws-lb-controller-iam-policy-json" {
  template = file("${path.module}//aws-lb-controller-iam-policy.json.tpl")
}

resource "aws_iam_policy" "aws_lb_controller_policy" {
  name_prefix = local.aws_load_balancer_controller_role_name
  description = "AWS load balancer controller policy for cluster ${module.eks.cluster_id}"
  policy      = data.template_file.aws-lb-controller-iam-policy-json.rendered
}

module "iam_assumable_aws_lb_controller_role" {
  source                        = "./modules/terraform-aws-iam-4.13.2/modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = local.aws_load_balancer_controller_role_name
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws_lb_controller_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.aws_load_balancer_controller_service_account}"]
}

resource "kubernetes_service_account" "aws-lb-controller-sa" {
  metadata {
    name      = local.aws_load_balancer_controller_service_account
    namespace = local.k8s_service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.aws_load_balancer_controller_role_name}"
    }
  }
}
