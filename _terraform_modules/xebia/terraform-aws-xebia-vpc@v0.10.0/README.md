# AWS VPC Terraform module

Terraform module which creates VPC resources on AWS.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.31 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.38 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.38 |

## Modules

AWS VPC module 

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpn_gateway_route_propagation.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagation) | resource |
| aws_route.tgw_route | resource |


## Inputs

| Name | Description |
|------|-------------|
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier | `string` | `""` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden | `string` | `"0.0.0.0/0"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones names or ids in the region | `list(string)` | `[]` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_private_subnet_tags"></a> [private\_subnet\_tags](#input\_private\_subnet\_tags) | Additional tags for the private subnets | `map(string)` | `{}` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnets inside the VPC | `list(string)` | `[]` | no |
| <a name="input_public_subnet_tags"></a> [public\_subnet\_tags](#input\_public\_subnet\_tags) | Additional tags for the public subnets | `map(string)` | `{}` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `false` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `false` | no |
| <a name="input_one_nat_gateway_per_az"></a> [one\_nat\_gateway\_per\_az](#input\_one\_nat\_gateway\_per\_az) | Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`. | `bool` | `false` | no |
| <a name="input_enable_flow_log"></a> [enable\_flow\_log](#input\_enable\_flow\_log) | Whether or not to enable VPC Flow Logs | `bool` | `false` | no |
| <a name="input_create_flow_log_cloudwatch_log_group"></a> [create\_flow\_log\_cloudwatch\_log\_group](#input\_create\_flow\_log\_cloudwatch\_log\_group) | Whether to create CloudWatch log group for VPC Flow Logs | `bool` | `false` | no |
| <a name="input_create_flow_log_cloudwatch_iam_role"></a> [create\_flow\_log\_cloudwatch\_iam\_role](#input\_create\_flow\_log\_cloudwatch\_iam\_role) | Whether to create IAM role for VPC Flow Logs | `bool` | `false` | no |
| <a name="input_flow_log_max_aggregation_interval"></a> [flow\_log\_max\_aggregation\_interval](#input\_flow\_log\_max\_aggregation\_interval) | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds. | `number` | `600` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | Additional tags for the VPC | `map(string)` | `{}` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the VPC | `bool` | `false` | no |
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | Controls if an Internet Gateway is created for public subnets and the related routes that connect them. | `bool` | `true` | no |
| <a name="transit_gateway_id"></a> [transit_gateway_id](#input\_transit_gateway_id_) | Transit gateway id to create attachment | (string) | `{}` | no |
| <a name="destination_cidr_block"></a> [destination_cidr_block](#input\_destination_cidr_block_) | CIDR block to create route | (string) | `{}` | no |
| <a name="peer_vpc_id"></a> [peer_vpc_id](#input\_peer_vpc_id_) |The ID of the VPC with which you are creating the VPC Peering Connection | (string) | `{}` | no |
| <a name="peer_owner_id"></a> [peer_owner_id](#input\_peer_owner_id_) | The AWS account ID of the owner of the peer VPC | (number) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azs"></a> [azs](#output\_azs) | A list of availability zones specified as argument to this module |
| <a name="output_default_vpc_id"></a> [default\_vpc\_id](#output\_default\_vpc\_id) | The ID of the Default VPC |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | The ARN of the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | The ID of the security group created by default on VPC creation |
| <a name="output_default_network_acl_id"></a> [default\_network\_acl\_id](#output\_default\_network\_acl\_id) | The ID of the default network ACL |
| <a name="output_default_vpc_instance_tenancy"></a> [default\_vpc\_instance\_tenancy](#output\_default\_vpc\_instance\_tenancy) | Tenancy of instances spin up within Default VPC |
| <a name="output_default_vpc_instance_tenancy"></a> [default\_vpc\_instance\_tenancy](#output\_default\_vpc\_instance\_tenancy) | Tenancy of instances spin up within Default VPC |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of IDs of private subnets |
| <a name="output_private_subnet_arns"></a> [private\_subnet\_arns](#output\_private\_subnet\_arns) | List of ARNs of private subnets |
| <a name="output_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#output\_private\_subnets\_cidr\_blocks) | List of cidr\_blocks of private subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of IDs of public subnets |
| <a name="output_public_subnet_arns"></a> [public\_subnet\_arns](#output\_public\_subnet\_arns) | List of ARNs of public subnets |
| <a name="output_public_subnets_cidr_blocks"></a> [public\_subnets\_cidr\_blocks](#output\_public\_subnets\_cidr\_blocks) | List of cidr\_blocks of public subnets |
| <a name="output_vpc_flow_log_id"></a> [vpc\_flow\_log\_id](#output\_vpc\_flow\_log\_id) | The ID of the Flow Log resource |
| <a name="output_vpc_flow_log_destination_arn"></a> [vpc\_flow\_log\_destination\_arn](#output\_vpc\_flow\_log\_destination\_arn) | The ARN of the destination for VPC Flow Logs |
| <a name="output_vpc_flow_log_destination_type"></a> [vpc\_flow\_log\_destination\_type](#output\_vpc\_flow\_log\_destination\_type) | The type of the destination for VPC Flow Logs |
| <a name="input_azs"></a> [azs](#input\_azs) | A list of availability zones names or ids in the region | `list(string)` | `[]` | no |
| <a name="output_name"></a> [name](#output\_name) | The name of the VPC specified as argument to this module |
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | The ID of the Internet Gateway |
| <a name="output_igw_arn"></a> [igw\_arn](#output\_igw\_arn) | The ARN of the Internet Gateway |
| <a name="output_transit_gateway_attachment_id"></a> [_transit_gateway_attachment\id](#output\transit_gateway_attachment\_id) | The ARN of the Transit Gateway Attachment ID |