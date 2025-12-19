output "user_names" {
  value = [for user in local.users : "${user.first_name} ${user.last_name}"]
}

output "users_passwords" {
  value = {
    for user, profile in aws_iam_user_login_profile.users :
    user => "password created - user must reset first login"
  }
  sensitive = true
}

output "group_members" {
  value = {
    Management = length(aws_iam_group_membership.management_members.users)
    Sales      = length(aws_iam_group_membership.sales_members.users)
    Accounting = length(aws_iam_group_membership.accounting_members.users)
    HR         = length(aws_iam_group_membership.hr_members.users)
  }
}