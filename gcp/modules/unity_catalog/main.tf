//generate a random string as the prefix for GCP resources, to ensure uniqueness
resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = "unity${random_string.naming.result}"
}



resource "google_storage_bucket" "unity_metastore" {
  name          = "${local.prefix}-metastore"
  location      = var.location
  force_destroy = true
}

resource "databricks_metastore" "this" {
  name          = "unity-catalog-${var.resource_prefix}"
  storage_root  = "gs://${google_storage_bucket.unity_metastore.name}"
  force_destroy = true
}

resource "databricks_metastore_data_access" "first" {
  metastore_id = databricks_metastore.this.id
  databricks_gcp_service_account {}
  name       = "the-keys"
  is_default = true
}

resource "google_storage_bucket_iam_member" "unity_sa_admin" {
  bucket = google_storage_bucket.unity_metastore.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${databricks_metastore_data_access.first.databricks_gcp_service_account[0].email}"
}

resource "google_storage_bucket_iam_member" "unity_sa_reader" {
  bucket = google_storage_bucket.unity_metastore.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${databricks_metastore_data_access.first.databricks_gcp_service_account[0].email}"
}

resource "databricks_metastore_assignment" "this" {
  count                = length(var.databricks_workspace_ids)
  workspace_id         = var.databricks_workspace_ids[count.index]
  metastore_id         = databricks_metastore.this.id
  default_catalog_name = "hive_metastore"
}

resource "databricks_catalog" "sandbox" {
  metastore_id = databricks_metastore.this.id
  name         = "sandbox"
  comment      = "this catalog is managed by terraform"
  properties = {
    purpose = "testing"
  }
  depends_on = [databricks_metastore_assignment.this]
}



resource "databricks_schema" "things" {
  catalog_name = databricks_catalog.sandbox.id
  name         = "things"
  comment      = "this database is managed by terraform"
  properties = {
    kind = "various"
  }
}



resource "google_storage_bucket" "ext_bucket" {
  name          = "${local.prefix}-ext-bucket"
  location      = var.location
  force_destroy = true
}

resource "databricks_storage_credential" "ext" {
  name = "the-creds"
  databricks_gcp_service_account {}
  depends_on = [databricks_metastore_assignment.this]
}

resource "google_storage_bucket_iam_member" "unity_cred_admin" {
  bucket = google_storage_bucket.ext_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${databricks_storage_credential.ext.databricks_gcp_service_account[0].email}"
}

resource "google_storage_bucket_iam_member" "unity_cred_reader" {
  bucket = google_storage_bucket.ext_bucket.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${databricks_storage_credential.ext.databricks_gcp_service_account[0].email}"
}

resource "databricks_grants" "external_creds" {
  storage_credential = databricks_storage_credential.ext.id
  grant {
    principal  = "mick2008nit@gmail.com"
    privileges = ["CREATE_TABLE"]
  }
}

resource "databricks_external_location" "some" {
  name = "the-ext-location"
  url  = "gs://${google_storage_bucket.ext_bucket.name}"

  credential_name = databricks_storage_credential.ext.id
  comment         = "Managed by TF"
  depends_on = [
    databricks_metastore_assignment.this,
    google_storage_bucket_iam_member.unity_cred_reader,
    google_storage_bucket_iam_member.unity_cred_admin
  ]
}

resource "databricks_grants" "some" {
  external_location = databricks_external_location.some.id
  grant {
    principal  = "mick2008nit@gmail.com"
    privileges = ["CREATE_TABLE", "READ_FILES"]
  }
}
