resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_iam_instance_profile" "this" {
  name = "${title(var.project_name)}Profile"
  role = aws_iam_role.ec2.name
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = join("", [title(var.project_name), "Template"])
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.this.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = var.project_name
      Environment = var.environment
    }
  }

  user_data = base64encode(
    templatefile(
      "${path.module}/ec2-startup.sh",
      {
        aws_region     = var.aws_region
        aws_account_id = var.aws_account_id
        ecr_url        = "${aws_ecr_repository.this.repository_url}:latest"
        container_port = var.container_port
        efs_id         = aws_efs_file_system.efs.id
      }
    )
  )

  lifecycle {
    ignore_changes = [image_id]
  }
}
