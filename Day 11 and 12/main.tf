# change to lowercase
##locals {
  ##formatted_project_name = lower(var.project_name)
##}

#replace space with hyphen
locals {
  formatted_project_name = lower(replace(var.project_name," ","-"))
  new_tags = merge(var.default_tags,var.environment_tags)
  formatted_bucket_name = replace(replace(substr(lower(var.bucket_name),0,40)," ",""),"!","")
  port_list = split(",", var.allowed_ports)
  sg_rules = [ for port in local.port_list :
    {
      name = "port-${port}"
      port = port
      description = "Allow trafic on port ${port}"
    }
  ]
  instance_size = lookup(var.instance_sizes,var.environment,"t2.micro")
  all_locations = concat(var.user_location,var.default_locations)
  unique_locations = toset(local.all_locations)
  positive_cost = [ for cost in var.monthly_costs : abs(cost) ]
  max_cost = max(local.positive_cost...)
  min_cost = min(local.positive_cost...)
  total_cost = sum(local.positive_cost)
  avg_cost = local.total_cost/length(local.positive_cost)

  current_timestamp = timestamp()
  format1 = formatdate(upper("yyyymmdd"), local.current_timestamp)
  format2 = formatdate("YYYY-MM-DD", local.current_timestamp)
  timestamp_name = "backup-${local.format1}"
  config_file_exists = fileexists("./config.json")
  config_data = local.config_file_exists ? jsondecode(file("./config.json")) : {}
}

resource "aws_s3_bucket" "hello_tech" {
  bucket = "hellodevopswithzacks"
  tags = local.new_tags#merge(var.default_tags,var.environment_tags)
}
resource "aws_s3_bucket" "firsts3" {
  bucket = local.formatted_bucket_name
  tags = local.new_tags #merge(var.default_tags,var.environment_tags)
}
resource "aws_secretsmanager_secret" "app_config" {
  name = "app-configuration-${formatdate("YYYYMMDD-hhmm", timestamp())}"
  description = "Application configuration from file"

  tags = {
    Name = "app-config"
    Sensitive = "true"
    ConfigFile = "./config.json"
  }
}
resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id = aws_secretsmanager_secret.app_config.id
  secret_string = jsonencode(local.config_data)
}
