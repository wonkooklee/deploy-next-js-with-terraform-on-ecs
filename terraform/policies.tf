resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  repository = aws_ecr_repository.wonkook_ecr_repo.name

  policy = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Keep last 3 images",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["v"],
            "countType": "imageCountMoreThan",
            "countNumber": 3
          },
          "action": {
            "type": "expire"
          }
        },
        {
          "rulePriority": 2,
          "description": "Expire untagged image",
          "selection": {
            "tagStatus": "untagged",
            "countType": "sinceImagePushed",
            "countUnit": "days",
            "countNumber": 1
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
  EOF
}
