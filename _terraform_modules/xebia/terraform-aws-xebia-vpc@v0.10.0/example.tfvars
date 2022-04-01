region                 = "ap-southeast-1"
name                   = "testVpc"
cidr                   = "172.16.100.0/22"
private_subnets        = ["172.16.100.0/24", "172.16.101.0/24"]
private_subnet_tags    = { "Type" : "Private" }
public_subnets         = []
public_subnet_tags     = {}
enable_nat_gateway     = false
one_nat_gateway_per_az = false
single_nat_gateway     = false
tags                   = { "Project Name" : "testVpc" }
#create_public_route           = false
#transit_gateway_id            = "tgw-0b1f2c68871b2929d"
#destination_cidr_block        = ["172.16.12.0/22", "172.12.12.0/22"]
manage_default_security_group  = true
default_security_group_ingress = []
default_security_group_egress  = []

/////////vpc endpoint ! 
create_endpoints = true
#security_group_ids = []
endpoints = {
  ssm = {
    service             = "ssm"
    private_dns_enabled = true
  },
  ssmmessages = {
    service             = "ssmmessages"
    private_dns_enabled = true
  },
  ec2messages = {
    service             = "ec2messages"
    private_dns_enabled = true
  },
}

ingress_rules_vpc_endpoints_sg = [
  {
    cidr_blocks = "172.16.12.0/22"
    from_port   = "443"
    to_port     = "443"
    protocol    = "TCP"
    description = "HTTPS"
}]
egress_rules_vpc_endpoints_sg = []


# enable_peering           = false
# peer_mode                = "sameaccount"
# accepter_vpc_id          = "vpc-0dae09c6ba55fa155"
# accepter_vpc_region      = "us-east-2"
# auto_accept_peering      = true
# accepter_route_table_ids = ["rtb-09cdf91252d57e72a"]

/*
# VPC Peering Same account
enable_peering      = true
peer_mode           = "sameaccount"
accepter_vpc_id     = "vpc-XX"
accepter_vpc_region = "us-east-1"
auto_accept_peering = true
accepter_route_table_ids  = ["rtb-XX"]
# VPC Peering Request
enable_peering      = true
peer_mode           = "requester"
accepter_vpc_id     = "vpc-XX"
accepter_vpc_region = "us-east-1"
# VPC Peering Accept
enable_peering            = true
accepter_vpc_region       = "ap-south-1"
peer_mode                 = "accepter"
vpc_peering_connection_id = "pcx-XX"
auto_accept_peering       = true
accepter_route_table_ids  = ["rtb-XX"]
*/ 