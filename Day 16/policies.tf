resource "aws_iam_policy" "force_mfa" {
  name        = "Force-MFA-Policy"
  description = "Users must enable MFA before accessing any AWS resources"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowViewAccountInfo"
        Effect = "Allow"
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:ListVirtualMFADevices",
          "iam:GetAccountSummary",
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnPasswords"
        Effect = "Allow"
        Action = [
          "iam:ChangePassword",
          "iam:GetUser",
        ]
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid    = "AllowManageOwnMFA"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ResyncMFADevice",
          "iam:ListMFADevice",
        ]
        Resource = [
          "arn:aws:iam::*:mfa/$${aws:username}",
          "arn:aws:iam::*:user/$${aws:username}",
        ]
      },
      #Deny all actions except MFA setup if MFA is not enabled
      {
        Sid    = "DenyAllExceptMFASetupIfNoMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevices",
          "sts:GetSessionToken",
          "iam:ChangePassword",
          "iam:GetAccountPasswordPolicy",
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultifactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

#Attach MFA policy to ALL users
resource "aws_iam_user_policy_attachment" "enforce_mfa" {
  for_each   = aws_iam_user.users
  policy_arn = aws_iam_policy.force_mfa.arn
  user       = each.value.name
}

#Management Full Access
resource "aws_iam_policy" "management_power_user" {
  name        = "management-power-user"
  description = "Full access to AWS services except IAM user/role management"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAllWithMFA"
        Action   = "*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid    = "DenyIAMUserManagement"
        Effect = "Deny"
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyAllWithoutMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevice",
          "iam:ListVirtualMFADevice",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken",
          "iam:ChangePassword"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultifactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
}

#Sales Policy Read Only Access
resource "aws_iam_policy" "sales_readonly" {
  name        = "sales-readonly-policy"
  description = "Read-only access to AWS resources for sales team"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadOnlyAccessWithMFA"
        Effect = "Deny"
        Action = [
          "ec2:Describe*",
          "s3:Get*",
          "s3:List*",
          "rds:Describe*",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "lambda:Get*",
          "lambda:List*",
          "dynamodb:Describe*",
          "dynamodb:List*",
          "dynamodb:Query",
          "dynamodb:Scan",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyAllWithoutMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevice",
          "iam:ListVirtualMFADevice",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken",
          "iam:ChangePassword"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultifactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
}

#Accounting Policy - Billing Access
resource "aws_iam_policy" "accounting_billing" {
  name        = "accounting-billing-policy"
  description = "Full billing and cost management access"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BillingAccessWithMFA"
        Effect = "Allow"
        Action = [
          "aws-portal:ViewBilling",
          "aws-portal:ViewPaymentMethods",
          "aws-portal:ViewAccount",
          "aws-portal:ViewUsage",
          "ce:*",
          "cur:*",
          "budgets:*",
          "pricing:*",
          "purchase-orders:*",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListObject",
        ]
        Resource = [
          "arn:aws:s3:::*billing*",
          "arn:aws:s3:::*billing*/*",
        ]
      },
      {
        Sid    = "DenyAllWithoutMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevice",
          "iam:ListVirtualMFADevice",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken",
          "iam:ChangePassword"
        ]
        Resource = ["*"]
        Condition = {
          BoolIfExists = {
            "aws:MultifactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
}

#HR Policy - IAm User Management
resource "aws_iam_policy" "hr_user_management" {
  name        = "HRUserManagementPolicy"
  description = "Manage IAM users, groups and credentials"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "UserManagementWithMFA"
        Effect = "Allow"
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:GetUser",
          "iam:ListUser",
          "iam:UpdateUser",
          "iam:CreateLoginProfile",
          "iam:DeleteLoginProfile",
          "iam:GetLoginProfile",
          "iam:UpdateLoginProfile",
          "iam:ChangePassword",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:ListAccessKey",
          "iam:UpdateAccessKey",
          "iam:AddUserToGroup",
          "iam:RemoveUserFromGroup",
          "iam:ListGroupsForUser",
          "iam:ListGroups",
          "iam:GetGroup",
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:DeactivateMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:ListMFADevice",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyRoleManagement"
        Effect = "Deny"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyAllWithoutMFA"
        Effect = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevice",
          "iam:ListVirtualMFADevice",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken",
          "iam:ChangePassword"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultifactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
}

resource "aws_iam_account_password_policy" "strong" {
  minimum_password_length        = 10
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  allow_users_to_change_password = true
  max_password_age               = 90

}