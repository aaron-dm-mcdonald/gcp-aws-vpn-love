variable "name" {
  type = string
  default = "vpn-test"
}

variable "aws_config" {
  type = object({
    region                = string
    vpc_cidr              = string
    public_subnet_a_cidr = string
    private_subnet_a_cidr = string
  })
  default = {
    region                = "us-east-2"
    vpc_cidr              = "10.10.0.0/16"
    public_subnet_a_cidr = "10.10.1.0/24"
    private_subnet_a_cidr = "10.10.10.0/24"
  }
}

# Usage:
# cidr_block = var.aws_config.public_subnet_a_cidr


variable "gcp_config" {
  type = object({
    region      = string
    subnet_cidr = string
  })
  default = {
    region      = "us-central1"
    subnet_cidr = "10.100.10.0/24"
  }
}

