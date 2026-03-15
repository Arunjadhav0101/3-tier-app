variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  default     = "three-tier-app"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "db_name" {
  description = "Database name"
  default     = "webappdb"
}

variable "db_user" {
  description = "Database master username"
  default     = "admin"
}

variable "db_password" {
  description = "Database master password"
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}
