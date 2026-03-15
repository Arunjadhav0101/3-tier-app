output "web_alb_dns_name" {
  description = "The DNS name of the web load balancer"
  value       = aws_lb.web_alb.dns_name
}

output "app_alb_dns_name" {
  description = "The DNS name of the internal app load balancer"
  value       = aws_lb.app_alb.dns_name
}

output "rds_cluster_endpoint" {
  description = "The cluster endpoint for Aurora"
  value       = aws_rds_cluster.aurora.endpoint
}
