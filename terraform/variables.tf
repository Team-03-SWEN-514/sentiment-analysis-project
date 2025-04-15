variable "instance_name"{
    description = "Value of the Name tag for EC2 instance"
    type = string
    default = "Group 3 Terraform Project"
}
variable "ec2_instance_type"{
    description = "My EC2 instance type"
    type = string
    default = "t2.micro"
}
variable "ami_id"{
    description = "AMI ID"
    type = string
    default = "ami-05ecb09ab7b9e1f90"
}
variable "key_pair"{
    description = "My keypair"
    type = string
    default = "EC2"
}
variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.0.0/26", "10.0.0.64/26"]

}

variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.0.128/26", "10.0.0.192/26"]
}

variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-2"  # Default value
}

variable "layer_bucket" {
  default = "swen514-team3-marketbucket" # Replace with your actual bucket
}

variable "amplify_github_oauth_token" {
  description = "OAuth token providing amplify access to the github repository"
  type = string
  default = "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"
}