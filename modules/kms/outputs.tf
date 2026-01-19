# KMS Module: outputs.tf

output "rds_kms_key_id" {
  description = "KMS key ID for RDS encryption"
  value       = aws_kms_key.rds.id
}

output "rds_kms_key_arn" {
  description = "KMS key ARN for RDS encryption"
  value       = aws_kms_key.rds.arn
}

output "secrets_kms_key_id" {
  description = "KMS key ID for Secrets Manager encryption"
  value       = aws_kms_key.secrets.id
}

output "secrets_kms_key_arn" {
  description = "KMS key ARN for Secrets Manager encryption"
  value       = aws_kms_key.secrets.arn
}

output "ebs_kms_key_id" {
  description = "KMS key ID for EBS encryption"
  value       = aws_kms_key.ebs.id
}

output "ebs_kms_key_arn" {
  description = "KMS key ARN for EBS encryption"
  value       = aws_kms_key.ebs.arn
}
