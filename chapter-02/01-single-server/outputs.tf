output "autoscaling_group_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web.name
}

output "launch_template_id" {
  description = "The ID of the EC2 Launch Template"
  value       = aws_launch_template.web.id
}