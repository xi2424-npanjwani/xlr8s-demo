# PROVIDER CONFIGURATION

variable "region" {
  description = "This is the region in which resources will be created"
  type        = string
  default     = "ap-south-1"
}
variable "assume_role_arn" {
  description = "Assume role in which account to create"
  type        = string
  default     = ""
}
variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Add extra tags to your resource"
}


# VPC CONFIGURATION

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}
variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
}
variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = null
}
variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}
variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}


//PUBLIC SUBNETS

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}
variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}
variable "create_igw" {
  description = "Controls if an Internet Gateway is created for public subnets and the related routes that connect them."
  type        = bool
  default     = true
}


//PRIVATE SUBNETS

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}
variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}
variable "enable_nat_gateway" {
  type        = bool
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}
variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = true
}
variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = bool
  default     = true
}


//LOGGING

variable "enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = true
}
variable "create_flow_log_cloudwatch_log_group" {
  description = "Whether to create CloudWatch log group for VPC Flow Logs"
  type        = bool
  default     = true
}
variable "create_flow_log_cloudwatch_iam_role" {
  description = "Whether to create IAM role for VPC Flow Logs"
  type        = bool
  default     = true
}
variable "flow_log_max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds."
  type        = number
  default     = 600
}


//TRANSIT GATEWAY AND ROUTES

variable "tgwa_tags" {
  description = "A map of tags to tgwa attachment"
  type        = map(string)
  default     = {}
}
variable "transit_gateway_id" {
  type    = string
  default = ""
}
variable "dns_support" {
  description = "Whether DNS support is enabled. Valid values: disable, enable"
  type        = string
  default     = "enable"
}
variable "ipv6_support" {
  description = "Whether IPv6 support is enabled. Valid values: disable, enable"
  type        = string
  default     = "disable"
}
variable "appliance_mode_support" {
  type    = bool
  default = false
}
variable "transit_gateway_default_route_table_association" {
  type    = bool
  default = false
}
variable "transit_gateway_default_route_table_propagation" {
  type    = bool
  default = false
}
variable "destination_cidr_block" {
  description = "The CIDR block for the private route table. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = list(string)
  default     = []
}
variable "create_public_route" {
  description = "Whether to create additional routes in public or private route tables of the vpc "
  type        = bool
  default     = false
}


//VPC ENDPOINTS

variable "create_endpoints" {
  description = "Determines whether resources will be created"
  type        = bool
  default     = false
}
variable "endpoints" {
  description = "A map of interface and/or gateway endpoints containing their properties and configurations"
  type        = map(any)
  default     = {}
}
variable "subnet_ids" {
  description = "Default subnets IDs to associate with the VPC endpoints"
  type        = list(string)
  default     = []
}

// VPC PEERING

variable "enable_peering" {
  type        = bool
  description = "Boolean value to determine whether to enable peering or not."
  default     = false
}
variable "peer_mode" {
  type        = string
  description = "Specifies the vpc peering mode"
  default     = "requester"
  validation {
    condition     = var.peer_mode == "accepter" || var.peer_mode == "requester" || var.peer_mode == "sameaccount"
    error_message = "The valid values for peer_mode are accepter, requester or sameaccount (case sensitive)."
  }
}
variable "accepter_vpc_id" {
  type        = string
  description = "The ID of the accepter VPC with which you are creating the VPC peering connection."
  default     = ""
}
variable "accepter_vpc_region" {
  type        = string
  description = "The region of the accepter VPC of the VPC Peering Connection."
  default     = "us-east-1"
}
variable "vpc_peering_connection_id" {
  type        = string
  description = "The VPC Peering Connection ID to manage."
  default     = ""
}
variable "auto_accept_peering" {
  type        = bool
  description = "Whether or not to accept the peering request."
  default     = false
}
variable "accepter_route_table_ids" {
  type        = list(string)
  description = "Comma separated value of Route table id, where the peering path will be added "
  default     = []
}


// VPC SECURITY GROUP

variable "manage_default_security_group" {
  description = "Should be true to adopt and manage default security group"
  type        = bool
  default     = false
}
variable "default_security_group_ingress" {
  description = "List of maps of ingress rules to set on the default security group"
  type        = list(map(string))
  default     = []
}
variable "default_security_group_egress" {
  description = "List of maps of egress rules to set on the default security group"
  type        = list(map(string))
  default     = []
}


//VPC ENDPOINTS SECURITY GROUP

variable "security_group_ids" {
  description = "Default security group IDs to associate with the VPC endpoints"
  type        = list(string)
  default     = []
}
variable "vpc_endpoints_sg_name" {
  description = "Give a name for vpc end points security group"
  type        = string
  default     = ""
}
variable "ingress_rules_vpc_endpoints_sg" {
  description = "List of maps of ingress rules to set on the vpc endpoint security group"
  type        = list(map(string))
  default     = []
}
variable "egress_rules_vpc_endpoints_sg" {
  description = "List of maps of egress rules to set on the vpc endpoint security group"
  type        = list(map(string))
  default     = []
}