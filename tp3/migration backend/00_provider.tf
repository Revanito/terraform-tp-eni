### Configuration de terraform
terraform {
  # Définir la version minimale requise de Terraform
  required_version = ">= 1.9.0"
  # Déclaration des providers requis
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.3" # Version 4.3 minimum, sans montées majeures
    }
    ##### BONUS1 #####
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
  }
  #################################################################
  ###                     MIGRATION BACKEND                     ###
  #################################################################

  #### avant de décommenter la suite faire  un terraform init / terraform apply
  #### créer le compte de stockage dans azure
  ###  dans azure faire : création compte de stokage : 
  ###  nom :  fthouin
  ###  groupe de ressource : rg-fthouin_cours-terraform
  ###  service principal : stockage blob azure ou azure data lake storage gen 2
  ###  region : france central
  ###  replication : LRS
  ###  performance : standard
  ###  ensuite faire :
  #### décomenté les ressources azurerm_storage_account.atelier3 celle avec ligne 67 à 105 
  ### FAIRE : export ARM_ACCESS_KEY=$(az storage account keys list --resource-group rg-fthouin_cours-terraform --account-name fthouin --query '[0].value' -o tsv)
  ## ^------- permet d'activé l'importation via terraform import sous linux
  #### terraform import azurerm_storage_account.atelier3 /subscriptions/ca5c57dd-3aab-4628-a78c-978830d03bbd/resourceGroups/rg-fthouin_cours-terraform/providers/Microsoft.Storage/storageAccounts/fthouin
  #### terraform apply
  #### commenter la partie backend local et décommenter la partie backend azurerm
  #### faire un terraform init -migrate-state pour migrer le backend
  #### faire un terraform apply pour vérifier que tout est ok
  # Configuration du backend local pour stocker l'état
  # backend "local" {
  #   path = "atelier3.tfstate"
  # }
  ### Pour activer la migration
  backend "azurerm" {
    resource_group_name  = "rg-fthouin_cours-terraform"
    storage_account_name = "fthouin"
    container_name       = "terraform-state"
    key                  = "atelier3/atelier3.tfstate"

  }
}
# Configuration du provider AzureRM
provider "azurerm" {
  features {} # Toutes les fonctionnalités par défaut
  use_cli         = true
  subscription_id = "ca5c57dd-3aab-4628-a78c-978830d03bbd" # ID récupéré depuis le portail Azure
}



#######################
### décomter la suite pour la phase 3 ###
resource "azurerm_storage_account" "atelier3" {
  name                            = "fthouin"
  resource_group_name             = data.azurerm_resource_group.rg_atelier3.name
  location                        = data.azurerm_resource_group.rg_atelier3.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false


  tags = {
    user = data.azurerm_resource_group.rg_atelier3.tags["user"]

  }
  blob_properties {
    change_feed_enabled      = false
    default_service_version  = null
    last_access_time_enabled = false
    versioning_enabled       = false
    container_delete_retention_policy {
      days = 7
    }
    delete_retention_policy {
      days                     = 7
      permanent_delete_enabled = false
    }
  }
  share_properties {
    retention_policy {
      days = 7
    }
  }
}
# #### pour la phase 3 :
resource "azurerm_storage_container" "terraform_state" {
  name                  = "terraform-state"
  storage_account_id    = azurerm_storage_account.atelier3.id
  container_access_type = "private"
}
