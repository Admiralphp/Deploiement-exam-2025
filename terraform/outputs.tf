# Outputs pour afficher les informations du déploiement

output "container_id" {
  description = "ID du conteneur Docker créé"
  value       = docker_container.cv_container.id
}

output "container_name" {
  description = "Nom du conteneur Docker"
  value       = docker_container.cv_container.name
}

output "container_image" {
  description = "Image Docker utilisée"
  value       = docker_container.cv_container.image
}

output "access_url" {
  description = "URL d'accès au CV"
  value       = "http://localhost:${var.external_port}"
}

output "container_status" {
  description = "Statut du conteneur"
  value       = docker_container.cv_container.status
}
