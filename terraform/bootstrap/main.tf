module "tfstate_storage" {
  source = "../modules/backend"

  location             = "canadacentral"
  resource_group_name  = "finaldevops-rg"
  storage_account_name = "stateblob"
  tags = {
    purpose = "terraform-remote-state"
  }
}
