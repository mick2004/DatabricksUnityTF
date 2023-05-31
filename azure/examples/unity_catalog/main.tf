module "unity_catalog" {
  source                      = "../../modules/unity_catalog/"

  databricks_resource_id = var.databricks_resource_id

}