cluster_name                    = "Test"
cluster_version                 = 1.21
cluster_endpoint_private_access = false
cluster_endpoint_public_access  = true
node_groups = [
  {
    "capacity_type" : "SPOT",
    "instance_types" : ["t3a.xlarge", "t3a.small"]
    "labels" : {
      "type" : "worker"
    },
    "max_capacity" : 4,
    "min_capacity" : 2,
    "name" : "worker-v1"
  }
  # {
  # "capacity_type" : "SPOT",
  # "instance_type" : "t3a.small",
  # "labels" : {
  # "type" : "worker"
  # },
  # "max_capacity" : 4,
  # "min_capacity" : 2,
  # "name" : "worker-spot-v1"
  # }
]
provider_key_arn                 = "arn:aws:kms:ap-south-1:xxxxxxx"
region                           = "ap-south-1"
required_labels                  = { "project" : "Test" }
extra_tags                       = { "Owner" : "Xebia", "ManagedBy" : "Terraform", "Purpose" : "test" }
existing_vpc_id                  = "vpc-xxxxx"
existing_vpc_subnets             = ["subnet-xxxxxx", "subnet-xxxxx"]
create_opensearch_sa             = true
create_prometheus_sa             = true
prometheus_amp_assume_role_arn   = "arn:aws:iam::xxxxxxx"
opensearch_write_assume_role_arn = "arn:aws:iam::xxxxxxx"
cluster_security_group_additional_rules = {
  ingress_self_all = {
    description = "Node to node all ports/protocols"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    type        = "ingress"
    self        = true
  },
  ingress_test = {
    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}
create_private_registry_secret = false
# cluster_create_endpoint_private_access_sg_rule = false
# cluster_endpoint_private_access_sg = ["sg-0d19fbba5fc6b38f1"]