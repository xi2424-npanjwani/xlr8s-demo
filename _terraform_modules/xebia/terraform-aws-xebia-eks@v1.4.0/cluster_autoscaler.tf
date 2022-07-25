
resource "helm_release" "cluster_autoscaler" {
  name = "cluster-autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.10.4"

  set {
    name  = "image.tag"
    value = var.cluster_autoscaler_image_tag
  }
  set {
    name  = "awsRegion"
    value = var.region
  }
  set {
    name  = "image.repository"
    value = var.cluster_autoscaler_image_repo
  }
  set {
    name  = "podAnnotations.cluster-autoscaler\\.kubernetes\\.io/safe-to-evict"
    value = "false"
    type  = "string"
  }

  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }

  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }

  set {
    name  = "rbac.create"
    value = true
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = local.cluster_autoscaler_service_account
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.aws_cluster_autoscaler_role_name}"
  }

  set {
    name  = "autoDiscovery.enabled"
    value = true
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "resources.requests.cpu"
    value = var.cluster_autoscaler_resources_requests_cpu
  }

  set {
    name  = "resources.requests.memory"
    value = var.cluster_autoscaler_resources_requests_memory
  }

  set {
    name  = "resources.limits.cpu"
    value = var.cluster_autoscaler_resources_limits_cpu
  }

  set {
    name  = "resources.limits.memory"
    value = var.cluster_autoscaler_resources_limits_memory
  }

  set {
    name  = "image.pullSecrets[0].name"
    value = var.create_private_registry_secret == true ? "private-registry-secret" : ""
  }
}

module "iam_assumable_cluster_autoscaler_role" {
  source                        = "./modules/terraform-aws-iam-4.13.2/modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = local.aws_cluster_autoscaler_role_name
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.cluster_autoscaler_service_account}"]
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name_prefix = local.aws_cluster_autoscaler_role_name
  description = "EKS cluster-autoscaler policy for cluster ${module.eks.cluster_id}"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}
