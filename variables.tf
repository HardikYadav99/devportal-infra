variable "aws_region" {
    description                     = "AWS region to deploy resources"
    type                            = string
    default                         = "ap-south-1"
}
variable "project_name" {
    description                     = "Add prefix to all resources"
    type                            = string
    default                         = "devportal"
}

variable "environment" {
    description                     = "Environment Name"
    type                            = string
    default                         = "dev"
}
variable "instance_type" {
    description                     = "EC2 Instance type"
    type                            = string
    default                         = "t3.large"
}
variable "ami_id" {
    description                     = "Ubuntu 22.04 AMI ID for ap-south-1"
    type                            = string
}

variable "key_name" {
    description                     = "Name of SSH Key pair"
    type                            = string
    default                         = "devportal-key"
  
}