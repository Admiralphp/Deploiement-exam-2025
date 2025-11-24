terraform {
  required_version = ">= 1.0"
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Configuration du timeout pour les téléchargements
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Configuration du provider Docker
provider "docker" {
  host = "unix:///var/run/docker.sock"
}
