
# Terraform S3 - creating a bucket

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# #Creating Iam user

# resource "aws_iam_user" "lb" {
#   name = "Adam"
# }

# #Iam policy for s3 access

# resource "aws_iam_policy" "policydocument" {
#   name        = "tf-policydocument"
#   policy      = data.aws_iam_policy_document.example.json
# }

# data "aws_iam_policy_document" "example" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "s3:ListBucket"
#     ]
#     resources = [
#       aws_s3_bucket.example.arn
#     ]
#   }
#   statement {
#     effect = "Allow"
#     actions = [
#       "s3:GetObject",
#       "s3:PutObject"
#     ]
#     resources = [
#       "${aws_s3_bucket.example.arn}/*"
#     ]
#   }
# }
variable "username" {
  type    =     list
  default = ["abdul", "khalid"]
}

#Creating users
resource "aws_iam_user" "newusers" {
  count = length(var.username)
  name  = element(var.username, count.index)
}

resource "aws_iam_user_policy_attachment" "ec2-user-full" {
  count      = length(var.username)
  user       = element(aws_iam_user.newusers.*.name, count.index)
  #policy_arn = "${aws_iam_policy.ec2_readonly.arn}"
  policy_arn = aws_iam_policy.ec2_full.arn
}

resource "aws_iam_policy" "ec2_full" {
  name = "ec2_full"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "transitgateway.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF
}

# outputs for arn
output "user_arn" {
  value = "${aws_iam_user.newusers.0.arn}"
}