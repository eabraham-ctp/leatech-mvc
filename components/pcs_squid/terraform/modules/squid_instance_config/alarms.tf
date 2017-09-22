resource "aws_cloudwatch_metric_alarm" "squid_net_bandwidth_high_alarm" {
  alarm_name                = "squid_net_bandwidth_high_alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "NetworkIn"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "750000000"
  alarm_description         = "Scale up if average NetworkIn > 750000000 for 5 minutes"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.squid_asg.name}"
  }

  alarm_actions     = ["${aws_autoscaling_policy.squid_asg_scaleup_policy.arn}"]
}
resource "aws_cloudwatch_metric_alarm" "squid_net_bandwidth_low_alarm" {
  alarm_name                = "squid_net_bandwidth_low_alarm"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "3"
  metric_name               = "NetworkIn"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "250000000"
  alarm_description         = "Scale down if average NetworkIn < 250000000 for 5 minutes"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.squid_asg.name}"
  }

  alarm_actions     = ["${aws_autoscaling_policy.squid_asg_scaledown_policy.arn}"]
}
