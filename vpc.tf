# Define data source for available AWS availability zones
data "aws_availability_zones" "available" {
  state = "available" # Retrieves only available zones
}

# Create a VPC
resource "aws_vpc" "medusa_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create Subnets within the VPC
resource "aws_subnet" "medusa_subnet" {
  count             = 2  # Creates 2 subnets in different availability zones
  vpc_id            = aws_vpc.medusa_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index] # Uses available zones
}

# Create a Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_security_group"
  description = "Security group for ECS"
  vpc_id      = aws_vpc.medusa_vpc.id

  # Inbound rules allowing HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
