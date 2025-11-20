output "rds_endpoint" {
  description = "Endpoint звичайної RDS"
  value       = var.use_aurora ? null : (length(aws_db_instance.standard) > 0 ? aws_db_instance.standard[0].endpoint : null)
}

output "aurora_cluster_endpoint" {
  description = "Aurora cluster writer endpoint"
  value       = var.use_aurora ? (length(aws_rds_cluster.aurora) > 0 ? aws_rds_cluster.aurora[0].endpoint : null) : null
}

output "aurora_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = var.use_aurora ? (length(aws_rds_cluster.aurora) > 0 ? aws_rds_cluster.aurora[0].reader_endpoint : null) : null
}

output "db_name" {
  description = "Назва бази даних"
  value       = var.db_name
}

output "db_port" {
  description = "Порт підключення до БД"
  value       = 5432
}
