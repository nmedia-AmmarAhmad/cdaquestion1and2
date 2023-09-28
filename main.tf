# Configure the AWS provider
provider "aws" {
  region = "ca-central-1"
}

resource "aws_s3_bucket" "mybuck" {
  bucket = "ammar-s3-bucket-hehe-updated-blue"
#   region = "ca-central-1"  # Replace with your desired region
}

#Policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#Role
resource "aws_iam_role" "example_role" {
  name               = "ammarexamplerole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# PolicyJSON
data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "example_policy" {
  name        = "test-policy"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_policy_attachment" "test_attach" {
  name       = "ammartestattachment"
  roles      = [aws_iam_role.example_role.name]
  policy_arn = aws_iam_policy.example_policy.arn
}

# Create a security group with port 3306 open for 0.0.0.0/0
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "Security group for MySQL"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an RDS instance with MySQL
resource "aws_db_instance" "my_rds_instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name              = "mydb"
  username             = "admin"
  password             = "Metro123"
  parameter_group_name = "default.mysql5.7"

  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
}

# Create a KMS key
resource "aws_kms_key" "my_kms_key" {
  description             = "My KMS Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# Create an Application Load Balancer (ALB)
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]
}

# Create an Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "my_asg" {
  name = "my-asg"
  launch_template {
    id = aws_launch_template.my_lt.id
  }
  vpc_zone_identifier = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
}

# Define a launch template for the Auto Scaling Group
resource "aws_launch_template" "my_lt" {
  name_prefix   = "my-lt-"
  instance_type = "t2.micro"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }
  image_id = "ami-0d301416ec25dc953"

}

# Create a VPC and subnets
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.50.0.0/16"
}
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "my_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.50.1.0/24"
  availability_zone = "ca-central-1a"
}

resource "aws_subnet" "my_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.50.2.0/24"
  availability_zone = "ca-central-1b"
}

resource "aws_subnet" "my_subnet3" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.50.3.0/24"
  availability_zone = "ca-central-1a"
}

resource "aws_subnet" "my_subnet4" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.50.4.0/24"
  availability_zone = "ca-central-1b"
}