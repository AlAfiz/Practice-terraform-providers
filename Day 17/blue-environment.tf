#Application Version 1.0 (Blue Environment - Production)
resource "aws_s3_object" "app_v1" {
  bucket = aws_s3_bucket.app_versions.id
  key    = "app-v1-zip"
  source = "${path.module}/app-v1/app-v1.zip"
  etag = filemd5("${path.module}/app-v1/app-v1.zip")

  tags = var.tags
}

resource "aws_elastic_beanstalk_application_version" "v1" {
  application = aws_elastic_beanstalk_application.app.name
  bucket      = aws_s3_bucket.app_versions.id
  key         =  aws_s3_object.app_v1.id
  name        = "${var.app_name}-v1"
  description = "Application Version 1.0 - Initial Release"

  tags = var.tags
}

#Blue Environment (Production)
resource "aws_elastic_beanstalk_environment" "blue" {
  name = "${var.app_name}-blue"
  application = aws_elastic_beanstalk_application.app.name
  solution_stack_name = var.solution_stack_name
  tier = "WebServer"
  version_label = aws_elastic_beanstalk_application_version.v1.name

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
    value     = "blue"
  }

  setting {
    name      = "VERSION"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "1.0"
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
      Environment = "blue"
      Role = "production"
    }
  )
}