resource "aws_security_group" "devportal" {
    name                        = "${var.project_name}-${var.environment}-sg"
    description                 = "Security Group for DevPortal k3 Instances"
    vpc_id                      = aws_vpc.main.id

    ingress {
        description             = "SSH from your IP"
        from_port               = 22
        to_port                 = 22
        protocol                = "tcp"
        cidr_blocks             =  ["0.0.0.0/0"]

    }

    ingress {
        description             = "HTTP"
        from_port               = 80
        to_port                 = 80
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    ingress {
        description             = "HTTPS"
        from_port               = 443
        to_port                 = 443
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    ingress {
        description             = "Kubernetes API server"
        from_port               = 6443
        to_port                 = 6443
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    ingress {
        description             = "NodePort range for Kubernetes Service"
        from_port               = 30000
        to_port                 = 32767
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"] 
    }
    egress {
        description             = "Allow all outbound traffic"
        from_port               = 0
        to_port                 = 0
        protocol                = "-1"
        cidr_blocks             = ["0.0.0.0/0"]
    }
    
    tags = {
        Name                    = "${var.project_name}-${var.environment}-sg"
        Project                 = var.project_name
        Environment             = var.environment
        ManagedBy               = "terraform"
    }
}