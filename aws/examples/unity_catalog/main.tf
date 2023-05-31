module "unity_catalog" {
  source                      = "../../modules/unity_catalog/"
  databricks_account_username       = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  databricks_account_id = var.databricks_account_id
 databricks_workspace_url       = var.databricks_workspace_url
  aws_account_id = var.aws_account_id
  tags = var.tags
  databricks_workspace_ids = var.databricks_workspace_ids
  databricks_users = var.databricks_users

  databricks_metastore_admins = var.databricks_metastore_admins
  unity_admin_group = var.unity_admin_group
}