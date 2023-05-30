resource "aws_codedeploy_app" "testing-app-cd" {
  compute_platform = "Server"
  name             = "testing-app-cd"
  depends_on       = [aws_instance.testing-instance]
}

resource "aws_codedeploy_deployment_config" "testing-app-config" {
  deployment_config_name = "testing-app-config"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 1
  }
}

resource "aws_iam_role" "testing-app-role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
    ]
  })

  tags = local.common_tags
}

resource "aws_codedeploy_deployment_group" "testing-app-deployment-group" {
  app_name               = aws_codedeploy_app.testing-app-cd.name
  deployment_group_name  = "testing-app-deployment-group"
  service_role_arn       = aws_iam_role.testing-app-role.arn
  deployment_config_name = aws_codedeploy_deployment_config.testing-app-config.id

  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = "ephemeral"
  }

  #   trigger_configuration {
  #     trigger_events     = ["DeploymentFailure"]
  #     trigger_name       = "foo-trigger"
  #     trigger_target_arn = "foo-topic-arn"
  #   }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  #   alarm_configuration {
  #     alarms  = ["my-alarm-name"]
  #     enabled = true
  #   }
}

