provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "nvarg" {
    name = "nva-rg"
    location = var.onpremise_location
}