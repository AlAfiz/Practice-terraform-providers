resource "aws_iam_group" "management" {
  name = "Management"
  path = "/groups/"
}

resource "aws_iam_group" "accounting" {
  name = "Accounting"
  path = "/groups/"
}

resource "aws_iam_group" "sales" {
  name = "Sales"
  path = "/groups/"
}

resource "aws_iam_group" "hr" {
  name = "hr"
  path = "/groups/"
}


resource "aws_iam_group_membership" "accounting_members" {
  name  = "accounting-group-membership"
  group = aws_iam_group.accounting.name
  users = [
    for user in aws_iam_user.users : user.name if user.tags.Department == "Accounting"
  ]
}

resource "aws_iam_group_membership" "management_members" {
  name  = "management-group-membership"
  group = aws_iam_group.management.name
  users = [
    for user in aws_iam_user.users : user.name if contains(keys(user.tags), "JobTitle") && can(regex("Manager|CEO", user.tags.JobTitle))
  ]
}

resource "aws_iam_group_membership" "sales_members" {
  name  = "sales-group-membership"
  group = aws_iam_group.sales.name
  users = [
    for user in aws_iam_user.users : user.name if user.tags.Department == "Sales"
  ]
}

resource "aws_iam_group_membership" "hr_members" {
  name  = "hr-group-membership"
  group = aws_iam_group.hr.name
  users = [
    for user in aws_iam_user.users : user.name if user.tags.Department == "HR"
  ]
}


#Attach Permissions to Groups

#Management Full Access
resource "aws_iam_group_policy_attachment" "management_policy" {
  group      = aws_iam_group.management.name
  policy_arn = aws_iam_policy.management_power_user.arn
}

#Sales ReadOnly Access
resource "aws_iam_group_policy_attachment" "sales_policy" {
  group      = aws_iam_group.management.name
  policy_arn = aws_iam_policy.sales_readonly.arn
}

#Accounting Billing Access
resource "aws_iam_group_policy_attachment" "accounting_policy" {
  group      = aws_iam_group.accounting.name
  policy_arn = aws_iam_policy.accounting_billing.arn
}

#hr user management Access
resource "aws_iam_group_policy_attachment" "hr_policy" {
  group      = aws_iam_group.hr.name
  policy_arn = aws_iam_policy.hr_user_management.arn
}