# ---------------------------------------------------------------------------
# AWS Secrets Manager — petclinic application secrets
# ---------------------------------------------------------------------------
# These are the secrets that External Secrets Operator (ESO) will sync
# into Kubernetes as a native Secret object for the petclinic app.
#
# Variables are declared in variables.tf. Override the password via:
#   export TF_VAR_petclinic_db_password="<your-password>"
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Secret: petclinic/database
# ---------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "petclinic_db" {
  name        = "petclinic/database"
  description = "PetClinic PostgreSQL credentials used by External Secrets Operator"

  # Set to 0 to force delete immediately when destroyed (avoids deletion scheduling blocks)
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name    = "petclinic-database-secret"
    App     = "petclinic"
    ManagedBy = "Terraform"
  })
}

resource "aws_secretsmanager_secret_version" "petclinic_db" {
  secret_id = aws_secretsmanager_secret.petclinic_db.id

  secret_string = jsonencode({
    username = var.petclinic_db_username
    password = var.petclinic_db_password
    url      = "jdbc:postgresql://${var.petclinic_db_host}:${var.petclinic_db_port}/${var.petclinic_db_name}"
  })

  # Ignore future changes to avoid overwriting secrets managed outside Terraform
  lifecycle {
    ignore_changes = [secret_string]
  }
}

# ---------------------------------------------------------------------------
# Outputs — useful for debugging / ansible group_vars
# ---------------------------------------------------------------------------
output "petclinic_secret_arn" {
  description = "ARN of the petclinic/database secret in Secrets Manager"
  value       = aws_secretsmanager_secret.petclinic_db.arn
}

output "petclinic_secret_name" {
  description = "Name of the petclinic/database secret in Secrets Manager"
  value       = aws_secretsmanager_secret.petclinic_db.name
}
