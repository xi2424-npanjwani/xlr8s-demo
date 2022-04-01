// PROVIDER 
provider "aws" {
  region = var.region
  default_tags {
    tags = var.extra_tags
  }
  assume_role {
    role_arn = var.assume_role_arn
  }
}
provider "aws" {
  alias  = "accepter"
  region = var.accepter_vpc_region
}

// DATA & LOCALS

data "aws_vpc" "accepter_vpc" {
  count = var.enable_peering && (var.peer_mode == "requester" || var.peer_mode == "sameaccount") ? 1 : 0
  id    = var.accepter_vpc_id
}

data "aws_vpc_peering_connection" "pc" {
  count = var.enable_peering && (var.peer_mode == "accepter" || var.peer_mode == "sameaccount") ? 1 : 0
  id    = var.peer_mode == "sameaccount" ? aws_vpc_peering_connection.this[0].id : var.vpc_peering_connection_id
}

data "aws_availability_zones" "az" {
  state = "available"
}

locals {
  az_list             = var.azs == null ? flatten(tolist(data.aws_availability_zones.az.names)) : var.azs
  all_route_table_ids = flatten(distinct(concat(module.vpc.public_route_table_ids, module.vpc.private_route_table_ids, module.vpc.database_route_table_ids, module.vpc.redshift_route_table_ids, module.vpc.elasticache_route_table_ids, module.vpc.intra_route_table_ids)))
}

// RESOURCES

module "vpc" {
  source                               = "./modules/terraform-aws-vpc-3.7.0"
  name                                 = var.name
  cidr                                 = var.cidr
  azs                                  = local.az_list
  private_subnets                      = var.private_subnets
  private_subnet_tags                  = var.private_subnet_tags
  public_subnets                       = var.public_subnets
  public_subnet_tags                   = var.public_subnet_tags
  create_igw                           = var.create_igw
  enable_nat_gateway                   = var.enable_nat_gateway
  single_nat_gateway                   = var.single_nat_gateway
  one_nat_gateway_per_az               = var.one_nat_gateway_per_az
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role
  flow_log_max_aggregation_interval    = var.flow_log_max_aggregation_interval
  tags                                 = var.tags
  vpc_tags                             = var.vpc_tags
  manage_default_security_group        = var.manage_default_security_group
  default_security_group_ingress       = var.default_security_group_ingress
  default_security_group_egress        = var.default_security_group_egress


}

// TGW ATtcahments & Routes

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_attachment" {
  count                                           = var.transit_gateway_id == "" ? 0 : 1
  subnet_ids                                      = module.vpc.private_subnets
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = module.vpc.vpc_id
  dns_support                                     = var.dns_support
  ipv6_support                                    = var.ipv6_support
  appliance_mode_support                          = var.appliance_mode_support ? "enable" : "disable"
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation
  tags                                            = var.tgwa_tags
}

resource "aws_route" "tgw_route" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 0 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[0]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

// vpc endpoints
module "vpc_endpoints" {
  source             = "./modules/terraform-aws-vpc-3.7.0/modules/vpc-endpoints"
  count              = var.create_endpoints ? 1 : 0
  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.security_group[0].security_group_id]
  subnet_ids         = module.vpc.private_subnets
  endpoints          = var.endpoints
  tags               = var.vpc_tags
}

//security-group-for-vpc-endpoints
module "security_group" {
  count  = var.create_endpoints ? 1 : 0
  source = "./modules/terraform-aws-security-group-4.8.0"

  name   = var.vpc_endpoints_sg_name
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = var.ingress_rules_vpc_endpoints_sg
  egress_with_cidr_blocks  = var.egress_rules_vpc_endpoints_sg
}

// VPC Peering

resource "aws_vpc_peering_connection" "this" {
  count         = var.enable_peering && (var.peer_mode == "requester" || var.peer_mode == "sameaccount") ? 1 : 0
  peer_vpc_id   = var.accepter_vpc_id
  peer_owner_id = data.aws_vpc.accepter_vpc[0].owner_id
  vpc_id        = module.vpc.vpc_id
  peer_region   = var.accepter_vpc_region
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-peering", var.name)
    }
  )
}

resource "aws_route" "requester_routes" {
  count                     = var.enable_peering && (var.peer_mode == "requester" || var.peer_mode == "sameaccount") ? length(module.vpc.private_route_table_ids) : 0
  route_table_id            = element(module.vpc.private_route_table_ids, count.index)
  destination_cidr_block    = data.aws_vpc.accepter_vpc[0].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this[0].id
}

resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  provider                  = aws.accepter
  count                     = var.enable_peering && (var.peer_mode == "accepter" || var.peer_mode == "sameaccount") ? 1 : 0
  vpc_peering_connection_id = var.peer_mode == "sameaccount" ? aws_vpc_peering_connection.this[0].id : var.vpc_peering_connection_id
  auto_accept               = var.auto_accept_peering
  tags                      = var.tags
}

resource "aws_route" "accepter_routes" {
  provider                  = aws.accepter
  count                     = var.enable_peering && (var.peer_mode == "accepter" || var.peer_mode == "sameaccount") ? length(var.accepter_route_table_ids) : 0
  route_table_id            = var.accepter_route_table_ids[count.index]
  destination_cidr_block    = data.aws_vpc_peering_connection.pc[0].cidr_block
  vpc_peering_connection_id = var.peer_mode == "sameaccount" ? aws_vpc_peering_connection.this[0].id : var.vpc_peering_connection_id
}


// handling multiple destination cidr blocks for now by duplication of resourse block 
// upto 20 destination cidrs handled for now 

resource "aws_route" "tgw_route1" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 1 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[1]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route2" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 2 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[2]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route3" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 3 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[3]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route4" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 4 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[4]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route5" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 5 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[5]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route6" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 6 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[6]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route7" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 7 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[7]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route8" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 8 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[8]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route9" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 9 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[9]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route10" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 10 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[10]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route11" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 11 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[11]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route12" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 12 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[12]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route13" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 13 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[13]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route14" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 14 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[14]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route15" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 15 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[15]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route16" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 16 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[16]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route17" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 17 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[17]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route18" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 18 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[18]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}

resource "aws_route" "tgw_route19" {
  count                  = length(module.vpc.private_route_table_ids) > 0 && length(var.destination_cidr_block) > 19 ? length(module.vpc.private_route_table_ids) : 0
  route_table_id         = var.create_public_route ? module.vpc.public_route_table_ids[count.index] : module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.destination_cidr_block[19]
  transit_gateway_id     = var.transit_gateway_id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_attachment,
  ]
  timeouts {
    create = "5m"
  }
}
