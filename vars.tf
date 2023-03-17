variable "env" {
  type        = string
  default     = "dev"
}


variable instance_type {
  type        = string
  default     = "t2.micro"
}
variable "ami_id" {
  type        = string
  default     = "ami-005f9685cb30f234b"
}
variable "number_of_instances" {
  type        = number
  default     = 1
}

variable "vpc_cidr_block" {
  type        = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

# variable "private_subnet_cidr_blocks" {
#   type        = list(string)
#   description = "CIDR block for private subnet"
# }


