#Application Version 1.0 (Green Environment - Staging)
resource "aws_s3_object" "app_v2" {
  bucket = aws_s3_bucket.app_versions.id
  key    = "app-v2-zip"
  source = "${path.module}/app-v2/app-v2.zip"
  etag = filemd5("${path.module}/app-v2/app-v2.zip")

  tags = var.tags
}

resource "aws_elastic_beanstalk_application_version" "v2" {
  application = aws_elastic_beanstalk_application.app.name
  bucket      = aws_s3_bucket.app_versions.id
  key         =  aws_s3_object.app_v2.id
  name        = "${var.app_name}-v2"
  description = "Application Version 2.0 - New Feature Release"

  tags = var.tags
}

#Blue Environment (Production)
resource "aws_elastic_beanstalk_environment" "green" {
  name = "${var.app_name}-green"
  application = aws_elastic_beanstalk_application.app.name
  solution_stack_name = var.solution_stack_name
  tier = "WebServer"
  version_label = aws_elastic_beanstalk_application_version.v2.name

  # IAM Settings
  setting {
    name      = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = aws_iam_instance_profile.eb_ec2_profile.name
  }

  setting {
    name      = "ServiceRole"
    namespace = "aws:elasticbeanstalk:environment"
    value     = aws_iam_role.eb_service_role.name
  }

  # Instance Settings
  setting {
    name      = "InstanceType"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = var.instance_type
  }

  # Environment Type (Load Balanced)
  setting {
    name      = "EnvironmentType"
    namespace = "aws:elasticbeanstalk:environment"
    value     = "LoadBalanced"
  }

  setting {
    name      = "LoadBalancerType"
    namespace = "aws:elasticbeanstalk:environment"
    value     = "application"
  }

  #Auto Scaling Settings
  setting {
    name      = "MinSize"
    namespace = "aws:autoscaling:asg"
    value     = "1"
  }

  setting {
    name      = "MaxSize"
    namespace = "aws:autoscaling:asg"
    value     = "2"
  }

  #Health Reporting
  setting {
    name      = "SystemType"
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    value     = "enhanced"
  }

  # Platform Settings
  setting {
    name      = "HealthCheckPath"
    namespace = "aws:elasticbeanstalk:environment:process:default"
    value     = "/"
  }
  setting {
    name      = "Port"
    namespace = "aws:elasticbeanstalk:environment:process:default"
    value     = "8080"
  }

  setting {
    name      = "Protocol"
    namespace = "aws:elasticbeanstalk:environment:process:default"
    value     = "HTTP"
  }

  # Environment Variables
  setting {
    name      = "Environment"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "green"
  }

  setting {
    name      = "VERSION"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "2.0"
  }

  # Deployment Policy
  setting {
    name      = "DeploymentPolicy"
    namespace = "aws:elasticbeanstalk:command"
    value     = "Rolling"
  }

  setting {
    name      = "BatchSizeType"
    namespace = "aws:elasticbeanstalk:command"
    value     = "Percentage"
  }

  setting {
    name      = "BatchSize"
    namespace = "aws:elasticbeanstalk:command"
    value     = "50"
  }

  # Managed Updates
  setting {
    name      = "ManagedActionsEnabled"
    namespace = "aws:elasticbeanstalk:managedactions"
    value     = "false"
  }

  tags = merge(
    var.tags,
    {
      Environment = "green"
      Role = "staging"
    }
  )
}