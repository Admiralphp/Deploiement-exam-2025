# Projet DevOps - CV One Page

## 🎯 Objectif du Projet

Ce projet implémente une chaîne CI/CD complète pour automatiser le déploiement d'une application web statique (CV One Page) en suivant les meilleures pratiques DevOps.

**Enseignant:** Wahid Hamdi  
**Examen Pratique DevOps - Novembre 2025**

---

## 📋 Table des Matières

- [Architecture](#-architecture)
- [Technologies Utilisées](#-technologies-utilisées)
- [Prérequis](#-prérequis)
- [Structure du Projet](#-structure-du-projet)
- [Partie I : Préparation de l'Environnement](#partie-i--préparation-de-lenvironnement)
- [Partie II : Automatisation avec Ansible](#partie-ii--automatisation-avec-ansible)
- [Partie III : Pipeline CI/CD avec Jenkins](#partie-iii--pipeline-cicd-avec-jenkins)
- [Partie IV : Déploiement avec Terraform](#partie-iv--déploiement-avec-terraform)
- [Partie V : Orchestration Kubernetes](#partie-v--orchestration-kubernetes-avec-k3s-et-argo-cd)
- [Partie VI : Monitoring avec Grafana Cloud](#partie-vi--supervision-avec-grafana-cloud)
- [Commandes Utiles](#-commandes-utiles)
- [Dépannage](#-dépannage)
- [Captures d'Écran](#-captures-décran)

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         GitHub Repository                        │
│                    (Code Source + Manifests)                     │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Jenkins CI/CD Pipeline                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ Checkout │→ │  Build   │→ │   Test   │→ │   Push   │      │
│  │   Code   │  │  Docker  │  │  Image   │  │ DockerHub│      │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘      │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                ┌───────────────┴───────────────┐
                ↓                               ↓
┌───────────────────────────┐   ┌───────────────────────────┐
│   Terraform Deployment    │   │    K3s + Argo CD GitOps   │
│   ┌──────────────────┐   │   │   ┌──────────────────┐   │
│   │ Docker Container │   │   │   │   Deployment     │   │
│   │    (moncv)       │   │   │   │   (2 replicas)   │   │
│   │   Port: 8585     │   │   │   │  Service: 30080  │   │
│   └──────────────────┘   │   │   └──────────────────┘   │
└───────────────────────────┘   └───────────────────────────┘
                │                               │
                └───────────────┬───────────────┘
                                ↓
                ┌───────────────────────────┐
                │    Grafana Cloud          │
                │  ┌─────────────────────┐ │
                │  │  VM Monitoring      │ │
                │  │  Docker Monitoring  │ │
                │  │  K8s Monitoring     │ │
                │  └─────────────────────┘ │
                └───────────────────────────┘
```

---

## 🛠 Technologies Utilisées

| Catégorie | Technologies |
|-----------|-------------|
| **Infrastructure** | VirtualBox, Ubuntu Server 24.04 |
| **IaC** | Ansible, Terraform |
| **Conteneurisation** | Docker, Docker Compose |
| **CI/CD** | Jenkins |
| **Orchestration** | Kubernetes (K3s), Argo CD |
| **Monitoring** | Grafana Cloud, Grafana Agent |
| **Version Control** | Git, GitHub |
| **Web** | HTML5, CSS3, Nginx |

---

## 📦 Prérequis

### Machine Hôte (Windows/Linux/Mac)
- VirtualBox >= 7.0
- Git
- Éditeur de code (VS Code recommandé)
- Compte GitHub
- Compte Docker Hub
- Compte Grafana Cloud (gratuit)
- Compte Slack (pour notifications)

### VM DEVOPS-LAB
- Ubuntu Server 24.04 LTS
- 4 Go RAM minimum
- 20 Go d'espace disque
- Processeur avec 2 cœurs minimum
- Connexion Internet

---

## 📁 Structure du Projet

```
cv-onepage/
├── README.md                      # Documentation principale
├── index.html                     # CV One Page (HTML5)
├── style.css                      # Styles CSS3
├── Dockerfile                     # Image Docker
├── nginx.conf                     # Configuration Nginx
├── docker-compose.yml             # Docker Compose
├── Jenkinsfile                    # Pipeline CI/CD
├── .dockerignore                  # Exclusions Docker
├── .gitignore                     # Exclusions Git
│
├── ansible/                       # Configuration Ansible
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
│       ├── system_update/
│       ├── docker/
│       ├── terraform/
│       └── jenkins/
│
├── terraform/                     # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── docker.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── README.md
│
├── kubernetes/                    # Manifests Kubernetes
│   ├── deployment.yml
│   ├── service.yml
│   ├── namespace.yml
│   ├── argocd-application.yml
│   ├── ingress.yml
│   ├── configmap.yml
│   ├── hpa.yml
│   └── README.md
│
└── scripts/                       # Scripts d'installation
    ├── setup-ssh.sh
    ├── install-k3s.sh
    ├── install-argocd.sh
    ├── install-grafana-agent.sh
    └── setup-devops-lab.sh
```

---

## Partie I : Préparation de l'Environnement

### 1. Création de la VM Ubuntu Server 24.04

#### Sur VirtualBox

1. **Créer une nouvelle VM**
   ```
   Nom: DEVOPS-LAB
   Type: Linux
   Version: Ubuntu (64-bit)
   Mémoire: 4096 MB
   Disque: 20 GB (VDI, allocation dynamique)
   ```

2. **Configuration réseau**
   - Adaptateur 1: NAT
   - Adaptateur 2: Réseau privé hôte (pour accès SSH)

3. **Installation Ubuntu Server 24.04**
   - Télécharger l'ISO: https://ubuntu.com/download/server
   - Monter l'ISO dans la VM
   - Suivre l'installation standard
   - Créer l'utilisateur: `mohamed` (mot de passe: `123`)
   - Installer OpenSSH Server

4. **Configuration post-installation**
   ```bash
   # Sur la VM
   sudo apt update && sudo apt upgrade -y
   sudo apt install -y openssh-server
   sudo systemctl enable ssh
   sudo systemctl start ssh
   
   # Obtenir l'IP de la VM
   ip addr show
   ```

### 2. Configuration de l'accès SSH

#### Sur votre machine hôte

```bash
# Générer une paire de clés SSH
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_devops -C "devops-lab"

# Copier la clé publique sur la VM
ssh-copy-id -i ~/.ssh/id_rsa_devops.pub mohamed@10.174.154.25

# Tester la connexion
ssh -i ~/.ssh/id_rsa_devops mohamed@10.174.154.25
```

#### Configuration SSH simplifiée

Créer/éditer `~/.ssh/config` :

```
Host devops-lab
    HostName 10.174.154.25
    User mohamed
    IdentityFile ~/.ssh/id_rsa_devops
    StrictHostKeyChecking no
```

Test : `ssh devops-lab`

---

## Partie II : Automatisation avec Ansible

### Installation d'Ansible

#### Sur votre machine hôte

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y ansible

# macOS
brew install ansible

# Windows (WSL)
sudo apt update && sudo apt install -y ansible
```

### Configuration Ansible

1. **Cloner le dépôt**
   ```bash
   mkdir -p ~/devops-exam
   cd ~/devops-exam
   git clone https://github.com/Admiralphp/Deploiement-exam-2025.git .
   cd ansible
   ```

2. **Éditer l'inventaire**
   ```bash
   nano inventory.ini
   ```
   
   Modifier l'IP de la VM :
   ```ini
   [devops_lab]
   10.174.154.25 ansible_user=mohamed ansible_ssh_private_key_file=~/.ssh/id_rsa_devops
   ```

3. **Tester la connexion**
   ```bash
   ansible devops_lab -i inventory.ini -m ping
   ```

### Exécution du playbook Ansible

#### Installation complète

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

#### Installation par rôle

```bash
# Mise à jour système uniquement
ansible-playbook -i inventory.ini playbook.yml --tags update

# Docker uniquement
ansible-playbook -i inventory.ini playbook.yml --tags docker

# Terraform uniquement
ansible-playbook -i inventory.ini playbook.yml --tags terraform

# Jenkins uniquement
ansible-playbook -i inventory.ini playbook.yml --tags jenkins
```

### Vérification de l'installation

```bash
# Sur la VM
ssh devops-lab

# Vérifier Docker
docker --version
docker ps

# Vérifier Terraform
terraform --version

# Vérifier Jenkins
sudo systemctl status jenkins
curl http://localhost:8080
```

---

## Partie III : Pipeline CI/CD avec Jenkins

### 1. Configuration initiale de Jenkins

#### Accès à Jenkins

```
URL: http://10.174.154.25:8080
```

#### Récupérer le mot de passe initial

```bash
ssh devops-lab
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

#### Installation des plugins

Installer les plugins suivants :
- Git
- Docker Pipeline
- Docker Plugin
- GitHub Integration
- Slack Notification
- Pipeline Stage View

### 2. Configuration des credentials

#### Docker Hub

1. Aller dans : `Manage Jenkins` → `Manage Credentials`
2. Cliquer sur `(global)` → `Add Credentials`
3. Type: `Username with password`
   - ID: `dockerhub-credentials`
   - Username: `mohamedessid`
   - Password: `votre-token-dockerhub`

#### Slack (optionnel)

1. Créer un Slack App : https://api.slack.com/apps
2. Activer Incoming Webhooks
3. Copier le Webhook URL
4. Dans Jenkins :
   - `Manage Jenkins` → `Configure System`
   - Section Slack
   - Workspace: `votre-workspace`
   - Credential: Ajouter le token

### 3. Création du pipeline Jenkins

1. **Nouveau Job**
   - `New Item` → `Pipeline`
   - Nom: `cv-onepage-pipeline`

2. **Configuration**
   - Description: `Pipeline CI/CD pour CV One Page`
   - ☑ GitHub project: `https://github.com/Admiralphp/Deploiement-exam-2025`
   - ☑ Poll SCM: `H/5 * * * *` (toutes les 5 minutes)

3. **Pipeline Definition**
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/votre-username/cv-onepage.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

4. **Personnaliser le Jenkinsfile**
   
   Éditer `Jenkinsfile` et remplacer :
   ```groovy
   DOCKERHUB_USERNAME = 'mohamedessid'
   GIT_REPO = 'https://github.com/Admiralphp/Deploiement-exam-2025.git'
   SLACK_CHANNEL = '#devops'
   ```

### 4. Test du pipeline

```bash
# Faire un commit
git add .
git commit -m "Test Jenkins pipeline"
git push origin main

# Surveiller Jenkins
# Le pipeline devrait se déclencher automatiquement après 5 min max
```

### 5. Vérification

- Consulter les logs Jenkins
- Vérifier l'image sur Docker Hub
- Consulter la notification Slack

---

## Partie IV : Déploiement avec Terraform

### 1. Préparation

```bash
ssh devops-lab
cd ~/devops-exam/terraform
```

### 2. Configuration

Éditer `terraform.tfvars` :

```hcl
docker_image     = "mohamedessid/cv-onepage:latest"
container_name   = "moncv"
external_port    = 8585
internal_port    = 80
restart_policy   = "unless-stopped"
```

### 3. Initialisation

```bash
terraform init
```

### 4. Planification

```bash
terraform plan
```

### 5. Application

```bash
terraform apply
```

Taper `yes` pour confirmer.

### 6. Vérification

```bash
# Vérifier le conteneur
docker ps | grep moncv

# Obtenir les outputs
terraform output

# Tester l'accès
curl http://localhost:8585
```

### 7. Accès depuis la machine hôte

```
URL: http://10.174.154.25:8585
```

Ouvrir dans un navigateur web.

### 8. Destruction (si nécessaire)

```bash
terraform destroy
```

---

## Partie V : Orchestration Kubernetes avec K3s et Argo CD

### 1. Installation de K3s

```bash
ssh devops-lab
cd ~/devops-exam/scripts

# Rendre le script exécutable
chmod +x install-k3s.sh

# Exécuter l'installation
./install-k3s.sh
```

### 2. Vérification de K3s

```bash
# Vérifier les nodes
kubectl get nodes

# Vérifier les pods système
kubectl get pods --all-namespaces

# Informations du cluster
kubectl cluster-info
```

### 3. Installation d'Argo CD

```bash
cd ~/devops-exam/scripts

# Rendre le script exécutable
chmod +x install-argocd.sh

# Exécuter l'installation
./install-argocd.sh
```

### 4. Accès à Argo CD

#### Via NodePort

```
URL: https://<IP_VM>:<NodePort>
Username: admin
Password: (voir output du script)
```

#### Via Port-Forward

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Puis accéder à: https://localhost:8080
```

### 5. Déploiement de l'application

#### Méthode 1: Via Argo CD UI

1. Login à Argo CD
2. Cliquer sur `+ NEW APP`
3. Remplir les champs :
   - Application Name: `cv-onepage-app`
   - Project: `default`
   - Repository URL: `https://github.com/Admiralphp/Deploiement-exam-2025.git`
   - Path: `kubernetes`
   - Cluster: `https://kubernetes.default.svc`
   - Namespace: `default`
4. Activer `AUTO-SYNC`
5. Cliquer sur `CREATE`

#### Méthode 2: Via kubectl

```bash
cd ~/devops-exam/kubernetes

# Éditer argocd-application.yml avec votre repo
nano argocd-application.yml

# Appliquer
kubectl apply -f argocd-application.yml
```

### 6. Vérification du déploiement

```bash
# Vérifier les pods
kubectl get pods -l app=cv-onepage

# Vérifier le service
kubectl get svc cv-onepage-service

# Vérifier les replicas
kubectl get deployment cv-onepage-deployment

# Logs
kubectl logs -l app=cv-onepage --tail=50
```

### 7. Accès à l'application

#### Via NodePort

```
URL: http://10.174.154.25:30080
```

#### Via Port-Forward

```bash
kubectl port-forward svc/cv-onepage-service 8080:80

# Accéder à: http://localhost:8080
```

### 8. Test de l'auto-sync

```bash
# Modifier le nombre de replicas
cd ~/devops-exam/kubernetes
nano deployment.yml

# Changer replicas: 2 en replicas: 3
# Commit et push

git add deployment.yml
git commit -m "Scale to 3 replicas"
git push origin main

# Argo CD synchronisera automatiquement
# Vérifier après quelques secondes
kubectl get pods -l app=cv-onepage
```

---

## Partie VI : Supervision avec Grafana Cloud

### 1. Création d'un compte Grafana Cloud

1. Aller sur : https://grafana.com/auth/sign-up/create-user
2. Créer un compte gratuit
3. Créer une stack (sélectionner la région la plus proche)

### 2. Obtenir les credentials

1. Dans Grafana Cloud, aller dans : `My Account` → `Stacks`
2. Cliquer sur votre stack
3. Noter :
   - Prometheus URL
   - Loki URL
   - Username
   - API Key

### 3. Configuration de Grafana Agent

```bash
ssh devops-lab
cd ~/devops-exam/scripts

# Éditer le script avec vos credentials
nano install-grafana-agent.sh

# Remplacer :
GRAFANA_CLOUD_URL="https://prometheus-prod-XX-XX.grafana.net/api/prom/push"
GRAFANA_CLOUD_USERNAME="XXXXX"
GRAFANA_CLOUD_API_KEY="YOUR_API_KEY"
GRAFANA_LOKI_URL="https://logs-prod-XX.grafana.net/loki/api/v1/push"

# Rendre exécutable et lancer
chmod +x install-grafana-agent.sh
./install-grafana-agent.sh
```

### 4. Vérification de Grafana Agent

```bash
# Vérifier le service
sudo systemctl status grafana-agent

# Voir les logs
sudo journalctl -u grafana-agent -f
```

### 5. Configuration des dashboards

#### Dashboard pour la VM

1. Dans Grafana Cloud, aller dans `Dashboards`
2. Cliquer sur `Import`
3. ID: `1860` (Node Exporter Full)
4. Sélectionner le data source Prometheus
5. Cliquer sur `Import`

#### Dashboard pour Docker

1. Import Dashboard ID: `893` (Docker Monitoring)
2. Sélectionner le data source Prometheus

#### Dashboard pour Kubernetes

1. Import Dashboard ID: `15661` (Kubernetes Cluster Monitoring)
2. Sélectionner le data source Prometheus

### 6. Configuration des alertes

1. Dans Grafana Cloud : `Alerting` → `Alert rules`
2. Créer une nouvelle règle :
   - Name: `CPU Usage High`
   - Query: `100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80`
   - Condition: `WHEN avg() OF query(A, 5m, now) IS ABOVE 80`
3. Ajouter un contact point (Email, Slack, etc.)

### 7. Visualisation

Accéder à Grafana Cloud et consulter :
- Métriques de la VM (CPU, RAM, Disk, Network)
- Métriques Docker (Containers, Images, CPU, Memory)
- Métriques Kubernetes (Pods, Nodes, Deployments)
- Logs système et applicatifs

---

## 🔧 Commandes Utiles

### Ansible

```bash
# Test de connexion
ansible devops_lab -i inventory.ini -m ping

# Exécuter une commande ad-hoc
ansible devops_lab -i inventory.ini -a "docker ps"

# Dry-run du playbook
ansible-playbook -i inventory.ini playbook.yml --check

# Mode verbose
ansible-playbook -i inventory.ini playbook.yml -vvv
```

### Docker

```bash
# Lister les conteneurs
docker ps -a

# Voir les logs
docker logs moncv -f

# Arrêter un conteneur
docker stop moncv

# Démarrer un conteneur
docker start moncv

# Supprimer un conteneur
docker rm -f moncv

# Voir les images
docker images

# Nettoyer Docker
docker system prune -a
```

### Terraform

```bash
# Formater le code
terraform fmt

# Valider la configuration
terraform validate

# Afficher l'état
terraform show

# Lister les ressources
terraform state list

# Voir une ressource spécifique
terraform state show docker_container.cv_container

# Importer un conteneur existant
terraform import docker_container.cv_container $(docker inspect -f {{.ID}} moncv)
```

### Kubernetes

```bash
# Contexte et cluster
kubectl config current-context
kubectl cluster-info

# Ressources
kubectl get all
kubectl get pods --all-namespaces
kubectl get svc
kubectl get deployments

# Décrire une ressource
kubectl describe pod <pod-name>
kubectl describe svc cv-onepage-service

# Logs
kubectl logs -f <pod-name>
kubectl logs -l app=cv-onepage --tail=100

# Exécuter une commande dans un pod
kubectl exec -it <pod-name> -- /bin/sh

# Port-forward
kubectl port-forward svc/cv-onepage-service 8080:80

# Scaler un deployment
kubectl scale deployment cv-onepage-deployment --replicas=3

# Redémarrer un deployment
kubectl rollout restart deployment cv-onepage-deployment

# Voir l'historique des déploiements
kubectl rollout history deployment cv-onepage-deployment

# Métriques
kubectl top nodes
kubectl top pods
```

### Argo CD

```bash
# Login via CLI
argocd login <IP_VM>:<NodePort> --insecure

# Lister les applications
argocd app list

# Obtenir le statut d'une app
argocd app get cv-onepage-app

# Synchroniser une app
argocd app sync cv-onepage-app

# Voir les logs de sync
argocd app logs cv-onepage-app

# Supprimer une app
argocd app delete cv-onepage-app
```

### Jenkins

```bash
# Redémarrer Jenkins
sudo systemctl restart jenkins

# Voir les logs
sudo journalctl -u jenkins -f

# Recharger la configuration
sudo systemctl reload jenkins
```

### Git

```bash
# Cloner le dépôt
git clone https://github.com/Admiralphp/Deploiement-exam-2025.git

# Statut
git status

# Ajouter des fichiers
git add .

# Commit
git commit -m "Description des modifications"

# Push
git push origin main

# Pull
git pull origin main

# Voir l'historique
git log --oneline --graph

# Créer une branche
git checkout -b feature/nouvelle-fonctionnalite
```

---

## 🐛 Dépannage

### Problèmes courants

#### 1. Ansible ne peut pas se connecter à la VM

```bash
# Vérifier SSH
ssh -i ~/.ssh/id_rsa_devops ubuntu@<IP_VM>

# Vérifier la clé
ls -la ~/.ssh/id_rsa_devops

# Tester la connexion Ansible
ansible devops_lab -i inventory.ini -m ping -vvv
```

#### 2. Jenkins ne démarre pas

```bash
# Vérifier les logs
sudo journalctl -u jenkins -n 50

# Vérifier Java
java -version

# Redémarrer Jenkins
sudo systemctl restart jenkins

# Vérifier le port
sudo netstat -tulpn | grep 8080
```

#### 3. Docker ne fonctionne pas

```bash
# Vérifier le service
sudo systemctl status docker

# Redémarrer Docker
sudo systemctl restart docker

# Vérifier les permissions
sudo usermod -aG docker $USER
# Déconnexion/reconnexion nécessaire
```

#### 4. K3s ne démarre pas

```bash
# Vérifier le service
sudo systemctl status k3s

# Voir les logs
sudo journalctl -u k3s -n 100

# Redémarrer K3s
sudo systemctl restart k3s

# Réinstaller K3s
curl -sfL https://get.k3s.io | sh -
```

#### 5. Argo CD ne synchronise pas

```bash
# Vérifier l'application
kubectl get application -n argocd

# Voir les événements
kubectl get events -n argocd --sort-by='.lastTimestamp'

# Forcer la synchronisation
argocd app sync cv-onepage-app --force
```

#### 6. Grafana Agent n'envoie pas de métriques

```bash
# Vérifier le service
sudo systemctl status grafana-agent

# Voir les logs
sudo journalctl -u grafana-agent -f

# Vérifier la configuration
sudo cat /etc/grafana-agent.yaml

# Redémarrer
sudo systemctl restart grafana-agent
```

---

## 📸 Captures d'Écran

### À inclure dans votre compte rendu

1. **VM VirtualBox**
   - Configuration de la VM
   - VM en cours d'exécution

2. **Ansible**
   - Exécution du playbook
   - Résultat de l'installation

3. **Jenkins**
   - Configuration du pipeline
   - Exécution réussie du pipeline
   - Logs du build
   - Image poussée sur Docker Hub

4. **Docker**
   - `docker ps` montrant le conteneur
   - Page web accessible via http://IP:8585

5. **Terraform**
   - `terraform plan`
   - `terraform apply`
   - `terraform output`

6. **Kubernetes**
   - `kubectl get nodes`
   - `kubectl get pods`
   - `kubectl get svc`
   - Application accessible via NodePort

7. **Argo CD**
   - Interface web Argo CD
   - Application synchronisée
   - Détails de l'application

8. **Grafana Cloud**
   - Dashboard VM
   - Dashboard Docker
   - Dashboard Kubernetes
   - Alertes configurées

9. **GitHub**
   - Dépôt avec tous les fichiers
   - Commits effectués

10. **Tests d'accès**
    - CV accessible depuis le navigateur
    - Toutes les URLs testées

---

## 📝 Livrables Attendus

- ✅ Dépôt GitHub public avec :
  - Code source du CV One Page
  - Scripts Ansible (roles complets)
  - Scripts Terraform
  - Jenkinsfile
  - Dockerfile et docker-compose.yml
  - Manifests Kubernetes
  - Scripts d'installation
  - README.md détaillé

- ✅ Pipeline Jenkins fonctionnel
- ✅ Image Docker sur Docker Hub
- ✅ Conteneur Docker accessible (port 8585)
- ✅ Cluster K3s avec application déployée via Argo CD
- ✅ Monitoring opérationnel sur Grafana Cloud
- ✅ Captures d'écran de toutes les étapes

---

## 🤝 Contribution

Projet réalisé dans le cadre de l'examen pratique DevOps.

**Étudiant:** [Votre Nom]  
**Enseignant:** Wahid Hamdi  
**Date:** Novembre 2025

---

## 📄 Licence

Ce projet est à usage éducatif.

---

## 🔗 Liens Utiles

- [Documentation Ansible](https://docs.ansible.com/)
- [Documentation Docker](https://docs.docker.com/)
- [Documentation Terraform](https://www.terraform.io/docs)
- [Documentation Jenkins](https://www.jenkins.io/doc/)
- [Documentation Kubernetes](https://kubernetes.io/docs/)
- [Documentation Argo CD](https://argo-cd.readthedocs.io/)
- [Documentation Grafana](https://grafana.com/docs/)

---

**Fin du README.md**
