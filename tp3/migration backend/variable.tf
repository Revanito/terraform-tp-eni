variable "virtual_networks" {
  description = "Configurations des réseaux virtuels et des sous-réseaux à créer."
  type = map(object({
    address_space = list(string)
    location      = string
    environment   = string
    subnets = list(object({
      name           = string
      address_prefix = string
    }))
  }))
  default = {
    Buster = {
      address_space = ["192.168.1.0/24"]
      location      = "France central"
      environment   = "Production"
      subnets = [
        {
          name           = "subnet1"
          address_prefix = "192.168.1.0/26"
        },
        {
          name           = "subnet2"
          address_prefix = "192.168.1.64/26"
        }
      ]
    }
    Bullseye = {
      address_space = ["192.168.2.0/24"]
      location      = "France central"
      environment   = "Production"
      subnets = [
        {
          name           = "subnet1"
          address_prefix = "192.168.2.0/25"
        }
      ]
    }
    Buzz = {
      address_space = ["192.168.3.0/24", "192.168.4.0/24"]
      location      = "France central"
      environment   = "Staging"
      subnets = [
        {
          name           = "subnet1"
          address_prefix = "192.168.3.0/26"
        },
        {
          name           = "subnet2"
          address_prefix = "192.168.3.64/26"
        },
        {
          name           = "subnet3"
          address_prefix = "192.168.4.0/26"
        }
      ]
    }
  }
}
