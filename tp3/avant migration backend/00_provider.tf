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
  # Configuration du backend local pour stocker l'état
  backend "local" {
    path = "atelier3.tfstate"
  }
}
# Configuration du provider AzureRM
provider "azurerm" {
  features {} # Toutes les fonctionnalités par défaut
  use_cli         = true
  subscription_id = "ca5c57dd-3aab-4628-a78c-978830d03bbd" # ID récupéré depuis le portail Azure
}
