data "template_file" "aws-opensearch-write-assume-policy-json" {
  template = file("${path.module}//fluentbit-assume-role-policy.json")
  vars = {
    opensearch_write_assume_role_arn = var.opensearch_write_assume_role_arn
  }
}

resource "aws_iam_policy" "fluentbit_policy" {
  count       = var.create_opensearch_sa == true ? 1 : 0
  name_prefix = "opensearch_write_assume_role_${var.cluster_name}"
  description = "AWS opensearch write assume role policy for cluster ${module.eks.cluster_id}"
  policy      = data.template_file.aws-opensearch-write-assume-policy-json.rendered
}

module "opensearch_write_assume_role" {
  count                         = var.create_opensearch_sa == true ? 1 : 0
  source                        = "./modules/terraform-aws-iam-4.13.2/modules/iam-assumable-role-with-oidc"
  create_role                   = var.create_opensearch_sa
  role_name                     = "opensearch_write_assume_role_${var.cluster_name}"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.fluentbit_policy[0].arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:logging:opensearch-sa"]
}

resource "kubernetes_service_account" "opensearch_sa" {
  count = var.create_opensearch_sa == true ? 1 : 0
  metadata {
    name      = "opensearch-sa"
    namespace = "logging"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/opensearch_write_assume_role_${var.cluster_name}"
    }
  }
}