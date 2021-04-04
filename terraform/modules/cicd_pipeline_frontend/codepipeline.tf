data "aws_s3_bucket" "artifacts" {
  bucket = var.artifact_bucket
  depends_on = [var.artifact_bucket]
}

data "aws_s3_bucket" "web-bucket" {
  bucket = var.web_bucket
  depends_on = [var.web_bucket]
}

data "template_file" "buildspec" {
  template = file(var.frontend_buildspec_filename)
  vars = {
    environment = var.environment
    application_name = var.application_name
  }
}

data "aws_codestarconnections_connection" "pipeline" {
  arn          = var.codestar_connection_arn
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.environment}-${var.application_name}-frontend-pipeline"
  role_arn = aws_iam_role.pipeline.arn

  tags = {
    Environment = var.environment
  }

  artifact_store {
    location = data.aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.pipeline.arn
        FullRepositoryId = var.repository
        BranchName       = var.monitored_branch
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        BucketName = data.aws_s3_bucket.web-bucket.bucket
        Extract = "true"
      }
    }
  }
}

resource "aws_iam_role" "pipeline" {
  name = "${var.environment}-${var.application_name}-frontend-pipeline"
  tags = {
    Environment = var.environment
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "pipeline" {
  name = "${var.environment}-${var.application_name}-frontend-pipeline"
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
        {
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:GetObjectVersion",
				"s3:GetBucketVersioning",
				"s3:PutObject",
                "s3:PutObjectAcl",
                "s3:PutObjectVersionAcl"
			],
			"Resource": [
                          "${data.aws_s3_bucket.artifacts.arn}/*",
                          "${data.aws_s3_bucket.web-bucket.arn}/*"
                        ]
		},
		{
			"Effect": "Allow",
			"Action": "s3:ListBucket",
			"Resource": [
                          "${data.aws_s3_bucket.artifacts.arn}/*",
                          "${data.aws_s3_bucket.web-bucket.arn}/*"
                        ]
		},
		{
			"Effect": "Allow",
			"Action": [
				"codebuild:BatchGetBuilds",
				"codebuild:StartBuild"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": "codestar-connections:UseConnection",
			"Resource": "${data.aws_codestarconnections_connection.pipeline.arn}"
		},
		{
			"Effect": "Allow",
			"Action": [
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:PutLogEventsBatch"
            ],
			"Resource": "arn:aws:logs:*"
		}
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "pipeline" {
  policy_arn = aws_iam_policy.pipeline.arn
  role = aws_iam_role.pipeline.name
}

resource "aws_cloudwatch_log_stream" "build" {
  log_group_name = var.log_group
  name = "${var.environment}/${var.application_name}/${var.repository}/${var.monitored_branch}"
}

resource "aws_codebuild_project" "build" {
  name          = "${var.environment}-${var.application_name}-frontend-build"
  description   = "${var.environment} ${var.application_name} Frontend Build"
  build_timeout = var.build_timeout
  queued_timeout = var.queued_timeout
  badge_enabled = var.build_badge_enabled
  service_role = aws_iam_role.pipeline.arn

  logs_config {
    cloudwatch_logs {
      group_name = var.log_group
      stream_name = aws_cloudwatch_log_stream.build.name
      status = "ENABLED"
    }
  }

  tags = {
    Environment = var.environment
  }

  artifacts {
    type           = "CODEPIPELINE"
    packaging      = "NONE"
  }

  environment {
    compute_type = var.build_compute_type
    image = var.build_image
    type = "LINUX_CONTAINER"
    privileged_mode = var.build_privileged  # only used when building docker images
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = data.template_file.buildspec.rendered
  }
}

resource "aws_iam_role" "build" {
  name = "${var.environment}-${var.application_name}-frontend-build"

  tags = {
    Environment = var.environment
  }

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Principal": {
               "Service": "codebuild.amazonaws.com"
           },
           "Action": "sts:AssumeRole"
       }
   ]
}
EOF
}
