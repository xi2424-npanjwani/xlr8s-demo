# Start by creating the local and cluster roles
resource "kubernetes_cluster_role" "roles" {
  # We need to make one cluster role for each item present in the array
  for_each = { for role in local.k8s_cluster_roles : role.name => role }

  metadata {
    name = each.value.name
    # TODO: Add the standard labels
  }

  dynamic "rule" {
    for_each = each.value.rules

    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_role" "roles" {
  # We need to make one local role for each item present in the array
  for_each = { for role in local.k8s_local_roles : role.name => role }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    # TODO: Add the standard labels
  }

  dynamic "rule" {
    for_each = each.value.rules

    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_cluster_role_binding" "binding" {
  for_each = { for role in local.k8s_cluster_roles : role.name => role }

  metadata {
    name = each.value.name
    # TODO: Add the standard labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = each.value.name
  }

  subject {
    kind      = "Group"
    name      = each.value.group
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [
    kubernetes_cluster_role.roles
  ]
}

resource "kubernetes_role_binding" "bindings" {
  for_each = { for role in local.k8s_local_roles : role.name => role }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    # TODO: Add the standard labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = each.value.name
  }

  subject {
    kind      = "Group"
    name      = each.value.group
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [
    kubernetes_role.roles
  ]
}