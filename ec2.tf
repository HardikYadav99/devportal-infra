resource "aws_instance" "devportal" {
    ami                     = var.ami_id
    instance_type           = var.instance_type
    key_name                = var.key_name
    subnet_id               = aws_subnet.public.id
    vpc_security_group_ids  = [aws_security_group.devportal.id] 
    
    root_block_device {
        volume_size = 30
        volume_type = "gp3"
        encrypted = true

        tags = {
            Name            = "${var.project_name}-${var.environment}-disk"
            Project         = var.project_name
            Environment     = var.environment
            ManagedBy       = "terraform"
        }
    }

    user_data = <<-EOF
      #!/bin/bash
      apt-get update -y
      apt-get install -y curl wget git unzip
    EOF

    tags = {
        Name                = "${var.project_name}-${var.environment}"
        Project             = var.project_name
        Environment         = var.environment
        ManagedBy           = "terraform"
    }
}

resource "aws_eip" "devportal" {
    instance                = aws_instance.devportal.id
    domain                  = "vpc"
  
    tags = {
        Name                = "${var.project_name}-${var.environment}-eip"
        Project             = var.project_name
        Environment         = var.environment
        ManagedBy           = "terraform"
    }
}