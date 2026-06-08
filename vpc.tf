resource "aws_vpc" "main" {
    cidr_block             = "10.0.0.0/16"
    enable_dns_hostnames    = true
    enable_dns_support     = true
  
    tags = {
        Name         = "${var.project_name}-${var.environment}-vpc"
        Project      = var.project_name
        Environment  = var.environment
        ManagedBy    = "terraform"
    }
}

resource "aws_subnet" "public" {
    vpc_id                      = aws_vpc.main.id
    cidr_block                  = "10.0.0.0/24"
    availability_zone           = "ap-south-1a"
    map_public_ip_on_launch     = true

    tags = {
        Name                   = "${var.project_name}-${var.environment}-public-subnet"
        Project                = var.project_name
        Environment            = var.environment
        ManagedBy              = "terraform"
  }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name                    = "${var.project_name}-${var.environment}-igw"
        Project                 = var.project_name
        Environment             = var.environment
        ManagedBy               = "terraform"
       
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name                    = "${var.project_name}-${var.environment}-public-rt"
        Project                 = var.project_name
        Environment             = var.environment
        ManagedBy               = "Terraform"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id               = aws_subnet.public.id
    route_table_id          = aws_route_table.public.id
}
