# Configure the AWS provider to use the correct region
provider "aws" {
  region = "eu-west-1"  # Ensure this is the region where you want to deploy the instance
}

# Data source to fetch the latest Amazon Linux AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source to fetch an existing key pair from your AWS account
data "aws_key_pair" "existing_key" {
  key_name = "MyKeyPair"  # Replace with the exact key pair name from AWS
}

# Define the security group allowing HTTP traffic on port 80 and SSH traffic on port 22
resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic-${timestamp()}"
  description = "Allow inbound HTTP traffic on port 80 and SSH on port 22"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world. You can limit this to specific IPs if needed.
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world. You can limit this to specific IPs if needed.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic-${timestamp()}"
  }
}

# Define the EC2 instance that will run your application
resource "aws_instance" "web" {
  ami           = data.aws_ami.latest_amazon_linux.id  # Fetch the latest Amazon Linux AMI
  instance_type = "t2.micro"  # Smallest instance type (free tier eligible)
  
  # Attach the security group and specify the key pair
  security_groups = [aws_security_group.allow_web_traffic.name]  
  key_name        = data.aws_key_pair.existing_key.key_name  # Use the existing key pair

  tags = {
    Name = "web-instance"
  }

  # Optional: You can add additional configurations like instance profile or monitoring here
}

# Output the EC2 instance's public IP address
output "instance_ip" {
  value = aws_instance.web.public_ip
}
