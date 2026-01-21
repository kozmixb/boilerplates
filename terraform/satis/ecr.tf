resource "aws_ecr_repository" "this" {
  name = "${var.environment}-${var.project_name}"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "base_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last ${var.image_retention} images"
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = var.image_retention
        },
        "action" = {
          "type" = "expire"
        }
      }
    ]
  })
}

