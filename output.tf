output "instance_id" {
    description         = "EC2 Instance ID"
    value               = aws_instance.devportal.id
}

output "elastic_ip" {
    description         = "Static Public Ip address of the instance"
    value               = aws_eip.devportal.public_ip
}
output "ssh_command" {
    description         = "Command to SSH into the instance"
    value               = "ssh -i ~/.ssh/devportal-key.pem ubuntu@${aws_eip.devportal.public_ip}"
}
output "instance_name" {
    description         = "Name tag of the instance"
    value               = "${var.project_name}-${var.environment}"
  
}