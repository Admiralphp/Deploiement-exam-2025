# Terraform README

## Prérequis

- Terraform installé (>= 1.0)
- Docker installé et en cours d'exécution
- Image Docker disponible sur Docker Hub

## Utilisation

### 1. Initialiser Terraform

```bash
cd terraform
terraform init
```

### 2. Personnaliser les variables

Éditer le fichier `terraform.tfvars` :

```hcl
docker_image     = "votre-username/cv-onepage:latest"
container_name   = "moncv"
external_port    = 8585
```

### 3. Planifier le déploiement

```bash
terraform plan
```

### 4. Appliquer le déploiement

```bash
terraform apply
```

### 5. Vérifier le déploiement

```bash
# Vérifier que le conteneur fonctionne
docker ps | grep moncv

# Tester l'accès
curl http://localhost:8585
```

### 6. Obtenir les outputs

```bash
terraform output
```

### 7. Détruire le déploiement

```bash
terraform destroy
```

## Structure des fichiers

```
terraform/
├── main.tf           # Configuration du provider
├── variables.tf      # Déclaration des variables
├── docker.tf         # Ressources Docker
├── outputs.tf        # Outputs
└── terraform.tfvars  # Valeurs des variables
```

## Commandes utiles

```bash
# Formater le code Terraform
terraform fmt

# Valider la configuration
terraform validate

# Afficher l'état actuel
terraform show

# Lister les ressources
terraform state list

# Afficher une ressource spécifique
terraform state show docker_container.cv_container
```
