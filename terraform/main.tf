provider "aws" {
  region = "us-west-2"  # Update with your preferred region
}

# Retrieve the default VPC ID in the specified region
data "aws_vpc" "default" {
  default = true
}

# Use the default security group in the specified region
data "aws_security_group" "default" {
  name = "default"
}

# Provision a security group for the client based on the server's security group
resource "aws_security_group" "client_sg" {
  name        = "client_sg"
  description = "Security group for client"

  # Use the same ingress rules as the server
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provision an EC2 instance for the client
resource "aws_instance" "client_instance" {
  ami                    = "ami-0c55b159cbfafe1f0"  # Ubuntu 22.04 LTS AMI, change as needed
  instance_type          = "t2.micro"
  key_name               = "capstoneproject-dice"  # SSH keypair name
  subnet_id              = data.aws_vpc.default.subnet_ids[0]  # Use the default subnet of the default VPC
  security_groups        = [data.aws_security_group.default.id, aws_security_group.client_sg.id]
  
  tags = {
    Name = "ClientInstance"
  }

  # Execute remote commands to set up Docker and run the client container
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d client-image:latest"  # Replace client-image:latest with your Docker image name and tag
    ]
  }

  # Copy client.py to the instance
  provisioner "file" {
    source      = "client.py"
    destination = "/home/ubuntu/client.py"  # Update with the path on your instance
  }

  # You can add more provisioners as needed, such as copying Dockerfile.client and requirements.txt
}

