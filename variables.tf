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