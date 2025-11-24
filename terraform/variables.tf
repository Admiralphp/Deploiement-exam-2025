# Variables pour le déploiement Docker

variable "docker_image" {
  description = "Nom de l'image Docker à déployer"
  type        = string
  default     = "votre-username/cv-onepage:latest"
}

variable "container_name" {
  description = "Nom du conteneur Docker"
  type        = string
  default     = "moncv"
}

variable "external_port" {
  description = "Port externe pour accéder au conteneur"
  type        = number
  default     = 8585
}

variable "internal_port" {
  description = "Port interne du conteneur"
  type        = number
  default     = 80
}

variable "restart_policy" {
  description = "Politique de redémarrage du conteneur"
  type        = string
  default     = "unless-stopped"
}
