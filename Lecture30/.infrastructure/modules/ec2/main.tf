resource "aws_instance" "web_server" {
  ami           = var.ami_id                     // AMI ID for the instance
  instance_type = var.instance_type              // Instance type (e.g., t3.micro)
  subnet_id     = var.subnet_id                  // Subnet to launch the instance in
  vpc_security_group_ids = [var.security_group_id] // <--- Now uses the passed security_group_id variable
  key_name      = var.key_pair_name              // SSH key pair name for access

  tags = {
    Name = var.instance_name // Tag the EC2 instance with its specific name
  }

  // User data to install a simple web server (busybox httpd) and serve a greeting.
  // This script runs when the instance first starts.
  user_data = <<-EOF
              #!/bin/bash
              # Write a simple HTML file
              echo "Hello from Terraform EC2!" > /home/ec2-user/index.html
              # Start busybox httpd to serve the index.html on port 80
              # 'nohup' keeps the process running after the script finishes
              # '-f' runs httpd in the foreground, '-p 80' binds to port 80
              # '&' runs the command in the background
              nohup busybox httpd -f -p 80 -h /home/ec2-user &
              EOF
}
