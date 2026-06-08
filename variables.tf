variable "aws_region" {
    description = "AWS region to deploy resources"
    type = string
    default = "ap-south-1"
}
variable "project_name" {
    description = "Add prefix to all resources"
    type = string
    default = "devportal"
}

variable "environment" {
    description = "Environment Name"
    type = string
    default = "dev"
}