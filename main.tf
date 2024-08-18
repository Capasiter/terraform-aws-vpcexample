terraform {
  required_version = "~> 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "ctx" {}

data "aws_default_tags" "ctx" {}

data "aws_region" "ctx" {}

locals {
  tags = merge(
    data.aws_default_tags.ctx.tags,
    var.tags
  )
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    { Name = var.name },
    local.tags
  )
}

resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.public

  tags = merge(
    { Name = each.key },
    local.tags
  )
}

resource "aws_internet_gateway" "igw" {
  count = var.enable_internet_gateway ? 1 : 0
}

resource "aws_internet_gateway_attachment" "igw" {
  count = var.enable_internet_gateway ? 1 : 0

  internet_gateway_id = aws_internet_gateway.igw[0].id
  vpc_id              = aws_vpc.vpc.id
}

locals {
  ngw_subnets = [
    for k, v in var.subnets : aws_subnet.subnets[k].id if v.public
  ]
}

resource "aws_nat_gateway" "ngw" {
  depends_on = [aws_internet_gateway.igw[0]]
  for_each   = toset(local.ngw_subnets)

  connectivity_type = "private"
  subnet_id         = each.value.key
}
```