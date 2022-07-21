data "template_file" "aws-prometheus-assume-policy-json" {
  template = file("${path.module}//amp-assume-role-policy.json")
  vars = {
    prometheus_amp_assume_role_arn = var.prometheus_amp_assume_role_arn
  }
}

resource "aws_iam_policy" "prometheus_amp_policy" {
  count       = var.create_prometheus_sa == true ? 1 : 0
  name_prefix = "prometheus_amp_assume_role_${var.cluster_name}"
  description = "AWS managed service for prometheus role policy for cluster ${module.eks.cluster_id}"
  policy      = data.template_file.aws-prometheus-assume-policy-json.rendered
}

module "prometheus_amp_assume_role" {
  count                         = var.create_prometheus_sa == true ? 1 : 0
  source                        = "./modules/terraform-aws-iam-4.13.2/modules/iam-assumable-role-with-oidc"
  create_role                   = var.create_prometheus_sa
  role_name                     = "prometheus_amp_assume_role_${var.cluster_name}"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.prometheus_amp_policy[0].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:monitoring:prometheus-amp-sa"]
}

resource "kubernetes_service_account" "prometheus_amp_sa" {
  count = var.create_prometheus_sa == true ? 1 : 0
  metadata {
    name      = "prometheus-amp-sa"
    namespace = "monitoring"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/prometheus_amp_assume_role_${var.cluster_name}"
    }
  }
}