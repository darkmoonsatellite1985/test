terraform {
  backend "s3" {
      bucket = "terraform-state-qsq6vzj3vuzphy1u4xxkeupr18v4reiqf4a2pyuwn4n74"
      key = "terraform/state"
      region = "us-west-2"
  }
}

resource "aws_instance" "Instance-yrbl-j" {
      ami = data.aws_ami.ubuntu_latest.id
      instance_type = "d2.2xlarge"
      tags = {
        Name = "Instance-yrbl-j"
      }
      lifecycle {
        ignore_changes = [ami]
      }
}

resource "aws_iam_user" "Instance-yrbl-j_iam" {
      name = "Instance-yrbl-j_iam"
}

resource "aws_iam_user_policy_attachment" "Instance-yrbl-j_iam_policy_attachment0" {
      user = aws_iam_user.Instance-yrbl-j_iam.name
      policy_arn = aws_iam_policy.Instance-yrbl-j_iam_policy0.arn
}

resource "aws_iam_policy" "Instance-yrbl-j_iam_policy0" {
      name = "Instance-yrbl-j_iam_policy0"
      path = "/"
      policy = data.aws_iam_policy_document.Instance-yrbl-j_iam_policy_document.json
}

resource "aws_iam_access_key" "Instance-yrbl-j_iam_access_key" {
      user = aws_iam_user.Instance-yrbl-j_iam.name
}

resource "aws_iam_role" "Lambda-hlaw-lambda-iam-role" {
      name = "Lambda-hlaw-lambda-iam-role"
      assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}"
}

resource "aws_lambda_function" "Lambda-hlaw" {
      function_name = "Lambda-hlaw"
      role = aws_iam_role.Lambda-hlaw-lambda-iam-role.arn
      filename = "outputs/index.js.zip"
      runtime = "nodejs14.x"
      source_code_hash = data.archive_file.Lambda-hlaw-archive.output_base64sha256
      handler = "index.main"
}

resource "aws_cloudwatch_event_rule" "Lambda-hlaw-warmer-rule" {
      name = "Lambda-hlaw-warmer"
      schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "Lambda-hlaw-warmer-target" {
      rule = aws_cloudwatch_event_rule.Lambda-hlaw-warmer-rule.name
      target_id = "Lambda"
      arn = aws_lambda_function.Lambda-hlaw.arn
}

resource "aws_lambda_permission" "Lambda-hlaw-warmer-permission" {
      statement_id = "AllowExecutionFromCloudWatch"
      action = "lambda:InvokeFunction"
      function_name = aws_lambda_function.Lambda-hlaw.arn
      principal = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.Lambda-hlaw-warmer-rule.arn
}

resource "aws_s3_bucket" "my-bucket" {
      bucket = "my-bucket"
}

resource "aws_s3_bucket_public_access_block" "my-bucket_access" {
      bucket = aws_s3_bucket.my-bucket.id
      block_public_acls = true
      block_public_policy = true
}

data "aws_iam_policy_document" "Instance-yrbl-j_iam_policy_document" {
      statement {
        actions = ["ec2:RunInstances", "ec2:AssociateIamInstanceProfile", "ec2:ReplaceIamInstanceProfileAssociation"]
        effect = "Allow"
        resources = ["arn:aws:ec2:::*"]
      }
      statement {
        actions = ["iam:PassRole"]
        effect = "Allow"
        resources = [aws_instance.Instance-yrbl-j.arn]
      }
}

data "aws_ami" "ubuntu_latest" {
      most_recent = true
      owners = ["099720109477"]
      filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64*"]
      }
      filter {
        name = "virtualization-type"
        values = ["hvm"]
      }
}

data "archive_file" "Lambda-hlaw-archive" {
      type = "zip"
      source_file = "index.js"
      output_path = "outputs/index.js.zip"
}



