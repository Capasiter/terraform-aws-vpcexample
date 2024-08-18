# Session 05 - CMB-TF

## Lab 1 - Authoring VPC Module

We're going to be creating a simple VPC module that deploys subnets and optionally the internet and NAT gateways. The module will be used to create a VPC with a public and private subnet in each availability zone.

Open the `terraform-labs` directory in Visual Studio Code and create a new directory from the terminal:

```shell
mkdir -p session-05/labs/terraform-aws-vpcexample
cd session-05/labs/terraform-aws-vpcexample
code .
```

Create a new file named `main.tf` and add the following code:

```terraform
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

Create a new file named `variables.tf` and add the following code:

```terraform
variable "name" {
  description = "VPC name."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 1))
    error_message = "CIDR block must be a valid CIDR range."
  }
}

variable "enable_dns_hostnames" {
  default     = false
  description = "(Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  type        = bool
}

variable "enable_dns_support" {
  default     = true
  description = "(Optional) A boolean flag to enable/disable DNS support in the VPC. Defaults to true."
  type        = bool
}

variable "tags" {
  default     = {}
  description = "(Optional) A map of tags to assign to the resource."
  type        = map(string)
}


variable "subnets" {
  default     = {}
  description = "A map of subnets to create in the VPC."
  type = map(object({
    cidr_block        = string
    availability_zone = string
    public            = optional(bool, false)
  }))
}

variable "enable_internet_gateway" {
  default     = false
  description = "(Optional) A boolean flag to enable/disable the Internet Gateway. Defaults to false."
  type        = bool
}

variable "enable_nat_gateway" {
  default     = false
  description = "(Optional) A boolean flag to enable/disable the NAT Gateway. Defaults to false."
  type        = bool

  validation {
    condition     = var.enable_internet_gateway && var.enable_nat_gateway || !var.enable_nat_gateway
    error_message = "NAT Gateway requires Internet Gateway to be enabled."
  }
}
```

Create a new file named `outputs.tf` and add the following code:

```terraform
output "arn" {
  description = "VPC ARN."
  value       = aws_vpc.vpc.arn
}

output "cidr_block" {
  description = "CIDR block for the VPC."
  value       = aws_vpc.vpc.cidr_block
}

output "id" {
  description = "VPC ID."
  value       = aws_vpc.vpc.id
}

output "name" {
  description = "VPC name."
  value       = aws_vpc.vpc.tags.Name
}

output "subnet_ids" {
  description = "Subnet IDs."
  value       = [for k, v in aws_subnet.subnets : v.id]
}
```

## Lab 2 - Git Repository

Live demo.

Initialize the module directory as a Git repository:

```shell
git init
```

On GitHub, sign in and create a new repository named `terraform-aws-vpcexample`.

Take the URL and add it as the remote origin:

```shell
git remote add origin <url>
```

Commit the changes and push them to the remote repository:

```shell
git add .
git commit -m "Initial commit"
git tag v1.0.0
git push -u origin main && git push --tags
```

## Lab 3 - Publishing a Module

Live demo.

Sign into https://registry.terraform.io with your GitHub account.

Publish a module by clicking on the "Publish" > "Module" link in the top navigation.

Select the `terraform-aws-vpcexample` repository and click "Publish".
