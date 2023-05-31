# DatabricksUnityTF


# Getting Started:

1. Clone this Repo 

2. Install [Terraform](https://developer.hashicorp.com/terraform/downloads)

3. Decide the respective cloud<<cloud>>

4. CD into <<cloud>>/examples

5. Rename `example.tfvars.template` to `example.tfvars`.Fill out `example.tfvars`.Configure databricks token on the machine.
 https://docs.gcp.databricks.com/dev-tools/cli/index.html#set-up-authentication-using-a-databricks-personal-access-token


6. Run `terraform init`

7. Run `terraform validate`

8. From `gcp` directory, run `terraform plan -var-file ../example.tfvars`

9. Run `terraform apply -var-file ../example.tfvars`