locals {
  # Création d'un nouveau dictionnaire modifié des réseaux virtuels
  modified_virtual_networks = {
    for key, vnet in var.virtual_networks :                     # Boucle sur chaque élément de "var.virtual_networks"
    "${substr(vnet.environment, 0, 4)}-${key}" => {             # Clé : concaténation des 4 premières lettres de "environment" et de la clé actuelle
      location          = vnet.location                         # Récupération de la localisation
      address_space     = vnet.address_space                    # Récupération de l'espace d'adressage
      environment       = lower(substr(vnet.environment, 0, 4)) # Conversion en minuscule des 4 premières lettres de "environment"
      addr_space_number = length(vnet.address_space)            # Calcul du nombre de plages d'adresses
    }
  }
}

locals {
  # Création d'un dictionnaire de sous-réseaux
  subnets = {
    for entry in flatten([                                 # On aplatit une liste imbriquée pour obtenir un seul niveau de liste
      for vnet_name, vnet_data in var.virtual_networks : [ # Boucle sur chaque réseau virtuel
        for subnet in vnet_data.subnets : {                # Boucle sur chaque sous-réseau dans un réseau virtuel
          key = "${vnet_name}-${subnet.name}"              # Création d'une clé unique combinant le nom du VNet et du sous-réseau
          value = {
            address_prefix = subnet.address_prefix                                 # Récupération du préfixe d'adresse du sous-réseau
            location       = vnet_data.location                                    # Récupération de la localisation du VNet
            subnet_name    = subnet.name                                           # Nom du sous-réseau
            vnet_name      = "${substr(vnet_data.environment, 0, 4)}-${vnet_name}" # Nom modifié du VNet pour correspondre au format précédemment défini
          }
        }
      ]
    ]) : entry.key => entry.value # Création du dictionnaire final où chaque clé unique pointe vers ses données
  }
}

