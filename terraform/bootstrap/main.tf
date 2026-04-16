# Bootstrap values (fixed for this project). Storage account names must be globally unique in Azure;
# if `terraform apply` fails with a name conflict, change `storage_account_name` here.
module "backend" {
  source = "../modules/backend"

  location             = "canadacentral"
  resource_group_name  = "finaldevops-rg"
  storage_account_name = "stateblob"
  container_name       = "state-storage"
  tags = {
    purpose = "terraform-remote-state"
  }
}
