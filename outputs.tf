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