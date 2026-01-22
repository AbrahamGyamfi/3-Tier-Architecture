# User Data Template Rendering
locals {
  user_data_rendered = base64encode(templatefile("${path.module}/user_data.sh", {
    secret_name = var.secret_name
    aws_region  = var.aws_region
    db_endpoint = var.db_endpoint
    db_name     = var.db_name
  }))
}
