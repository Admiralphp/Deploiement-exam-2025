# Récupérer l'image Docker depuis Docker Hub
resource "docker_image" "cv_image" {
  name         = var.docker_image
  keep_locally = false
}

# Créer le conteneur Docker
resource "docker_container" "cv_container" {
  name  = var.container_name
  image = docker_image.cv_image.image_id

  # Configuration du port
  ports {
    internal = var.internal_port
    external = var.external_port
    protocol = "tcp"
  }

  # Politique de redémarrage
  restart = var.restart_policy

  # Labels
  labels {
    label = "com.example.project"
    value = "cv-onepage"
  }

  labels {
    label = "com.example.managed-by"
    value = "terraform"
  }

  # Healthcheck
  healthcheck {
    test         = ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
    interval     = "30s"
    timeout      = "10s"
    start_period = "5s"
    retries      = 3
  }

  # Logs
  log_driver = "json-file"
  log_opts = {
    max-size = "10m"
    max-file = "3"
  }
}
