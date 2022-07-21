# AWS Elastic Kubernetes Service (AWS EKS)

Terraform pipeline to create an EKS Cluster


## Resources Created

- EKS Cluster
- Security Groups for EKS 
- EKS Configuration
- IAM policies and roles for IRSA and Cluster Autoscaler 

## Best Practices
- Enable IRSA for providing access to AWS Resources
- Setting up cluster autoscaler for worker nodes
- Using managed node groups for worker nodes
- Setting up cluster across multiple azs.
- Use IAM Roles to manage authentication

## Direct Dependencies
| Name                      | Version       | Link
| ---                       | ---           | ---
| Terraform                 | >= 0.13.1     | N/A
| AWS Provider              | ~> 3.40.0     | https://registry.terraform.io/providers/hashicorp/aws/latest
| Local provider            | ~> 1.4        | https://registry.terraform.io/providers/hashicorp/local/latest
| Kubernetes provider       | ~> 2.2.0      | https://registry.terraform.io/providers/hashicorp/kubernetes/latest
| Helm provider             | ~> 2.1.2      | https://registry.terraform.io/providers/hashicorp/helm/latest
| EKS Module (not verified) | ~> 18.8.1     | https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v18.8.1
| IAM Module (not verified) | 3.6.0         | https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

## Inputs

| Name              | Description                         | Type            | Default       | Required
| ---               | ---                                 | ---             | ---           | ---     
| `region`          | The AWS Region                      | `string`        | `ap-south-1`  | yes 
| `cluster_name`    | Name of the EKS cluster             | `string`        | `null`        | yes 
| `cluster_version` | K8s Version                         | `string`        | `1.20`        | yes
| `required_labels` | Required labels                     | `object`        | `null`        | yes
| `node_groups`     | Create a necessary node groups      | `list(object)`  | Refer code    | yes
| `existing_vpc`    | The parameters to use exsiting VPC  | `object`        | Refer code    | no
| `map_aws_roles`   | Additional IAM roles to add to the aws-auth configmap | `list(object)` | Refer code | no
| `map_k8s_roles`   | Additional k8s roles to add to the cluster | `list(object)` | Refer code | no
| `namespaces`      | Create namespaces                          | `list(string)` | `[]`       | no
| `node_groups_defaults`      | Map of values to be applied to all node groups. See node_groups module's documentation for more details	                          | any | `{}`       | no
| `cluster_endpoint_private_access`      | Indicates whether or not the Amazon EKS private API server endpoint is enabled.	                          | bool | `false`       | no
| `cluster_endpoint_public_access`      | Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to false ensure to have a proper private access with cluster_endpoint_private_access = true	                          | bool | `true`       | no
`cluster_enabled_log_types`      | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)                         | list(string) | `[]`       | no
`cluster_create_endpoint_private_access_sg_rule`      | Whether to create security group rules for the access to the Amazon EKS private API server endpoint. When is true, cluster_endpoint_private_access_cidrs must be setted.                  | bool | `false`       | no
`cluster_endpoint_private_access_sg`      | List of security group IDs which can access the Amazon EKS private API server endpoint. To use this cluster_endpoint_private_access and cluster_create_endpoint_private_access_sg_rule must be set to true.                  | list(string) | `null`       | no
`cluster_autoscaler_image_tag`      | Cluster Autoscaler image tag that matches the Kubernetes major and minor version of your cluster     | string | `v1.21.0`       | no
`cluster_autoscaler_resources_requests_cpu`      | Cluster Autoscaler CPU request  | string | `100m`       | no
`cluster_autoscaler_resources_requests_memory`      | Cluster Autoscaler memory request | string | `300Mi`       | no
`cluster_autoscaler_resources_limits_memory`      | Cluster Autoscaler memory limits | string | `300Mi`       | no
`cluster_autoscaler_resources_limits_cpu`      | Cluster Autoscaler memory limits | string | `100m`   | no
`aws_lb_controller_resources_request_cpu`      | AWS Load Balancer Controller CPU request   | string | `100m`       | no
`aws_lb_controller_resources_request_memory`      | AWS Load Balancer Controller memory request   | string | `128Mi`       | no
`aws_lb_controller_resources_limits_cpu`      | AWS Load Balancer Controller CPU limits   | string | `100m`  | no
`aws_lb_controller_resources_limits_memory`      | AWS Load Balancer Controller memory limits  | string | `128Mi`  | no
`aws_lb_controller_ingress_class`      | AWS Load Balancer Controller ingress class | string | `alb`  | no
`enable-shield`      | Enable Shield addon for ALB -update to false when creating private EKS Cluster | boolean	 | `true`  | yes
`enable-waf`      | Enable WAF addon for ALB- update to false when creating private EKS Cluster| boolean	 | `true`  | yes
`enable-wafv2`      | Enable WAF V2 addon for ALB- update to false when creating private EKS Cluster | boolean	 | `true`  | yes

## Outputs

| Name                        | Description
| ---                         | ---
| `cluster_endpoint`          | Endpoint for EKS control plane.
| `cluster_security_group_id` | Security group ids attached to the cluster control plane.
| `kubectl_config`            | kubectl config as generated by the module.
| `config_map_aws_auth`       | A kubernetes configuration to authenticate to this EKS cluster.
| `region`                    | AWS region.
| `node_groups`               | Outputs from node groups.
