module "network" {
  source = "../../modules/network"

  location            = var.location
  group_number        = var.group_number
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

module "acr" {
  source = "../../modules/acr"

  name                = "cst8918group${var.group_number}acr"
  location            = var.location
  resource_group_name = module.network.resource_group_name
  tags                = var.tags
}
