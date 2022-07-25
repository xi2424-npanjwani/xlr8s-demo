module "eks" {
  source                                = "./modules/terraform-aws-eks-18.8.1"
  cluster_name                          = var.cluster_name
  cluster_version                       = var.cluster_version
  tags                                  = var.required_labels
  vpc_id                                = var.existing_vpc_id
  subnet_ids                            = var.existing_vpc_subnets
  cluster_enabled_log_types             = var.cluster_enabled_log_types
  cluster_additional_security_group_ids = var.cluster_endpoint_private_access_sg
  cluster_endpoint_private_access       = var.cluster_endpoint_private_access
  cluster_endpoint_public_access        = var.cluster_endpoint_public_access
  node_security_group_additional_rules  = var.node_security_group_additional_rules
  cluster_encryption_config = [{
    provider_key_arn = var.provider_key_arn == "" ? aws_kms_key.eks_key[0].arn : var.provider_key_arn
    resources        = ["secrets"]
  }]
  eks_managed_node_group_defaults = var.node_groups_defaults
  eks_managed_node_groups = {
    for group in var.node_groups : group.name => {
      desired_size   = group.min_capacity
      max_size       = group.max_capacity
      min_size       = group.min_capacity
      instance_types = group.instance_types
      capacity_type  = group.capacity_type
      labels         = merge(var.required_labels, group.labels)
    }
  }
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
}

# Generating kms key in case no key is provided

resource "aws_kms_key" "eks_key" {
  count               = var.provider_key_arn == "" ? 1 : 0
  description         = "Key for EKS Secret Encryption"
  enable_key_rotation = true
}


################################################################################
# aws-auth configmap
# Only EKS managed node groups automatically add roles to aws-auth configmap
# to add custom roles/users workaround is to patch using kubectl
################################################################################

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })
  current_auth_configmap = yamldecode(module.eks.aws_auth_configmap_yaml)

  updated_auth_configmap_data = {
    data = {
      mapRoles = replace(yamlencode(
        distinct(concat(
          yamldecode(local.current_auth_configmap.data.mapRoles), var.map_aws_roles)
      )), "\"", "")
      mapUsers = yamlencode(var.map_aws_users)
    }
  }
  k8s_namespace_secrets = var.create_private_registry_secret == true ? concat(var.existing_system_namespaces, var.add_namespaces[*].name) : []
}

resource "null_resource" "patch_aws_auth_configmap" {
  triggers = {
    cmd_patch = "kubectl patch configmap/aws-auth -n kube-system --type merge -p '${chomp(jsonencode(local.updated_auth_configmap_data))}' --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = self.triggers.cmd_patch

    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }
  }
}
# create namespaces
resource "kubernetes_namespace" "ns" {
  for_each = { for vm in var.add_namespaces : vm.name => vm }
  metadata {
    labels = "${each.value.enable_istio}" == true ? { managedby = "terraform", istio-injection = "enabled" } : { managedby = "terraform", istio-injection = "disabled" }
    name   = each.value.name
  }

}
# Deploying Image pull secret to EKS cluster
resource "kubernetes_secret" "eks" {
  for_each = toset(local.k8s_namespace_secrets[*])
  metadata {
    name      = "private-registry-secret"
    namespace = each.value
    labels = {
      managedby = "terraform"
    }
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "${var.registry_server}": {
      "auth": "${base64encode("${var.registry_username}:${var.registry_password}")}"
    }
  }
}
DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}
