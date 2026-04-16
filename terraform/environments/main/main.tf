module "network" {
  source = "../../modules/network"

  location            = var.location
  group_number        = var.group_number
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
