# Configuration de l'Environnement

## 📋 Informations du Projet

**Étudiant:** Mohamed  
**Date:** Novembre 2025  
**Enseignant:** Wahid Hamdi

---

## 🖥️ Configuration de la VM

| Paramètre | Valeur |
|-----------|--------|
| **Nom** | DEVOPS-LAB |
| **OS** | Ubuntu Server 24.04 LTS |
| **IP** | 10.174.154.25 |
| **Utilisateur** | mohamed |
| **Mot de passe** | 123 |
| **RAM** | 4 Go |
| **Disque** | 20 Go |
| **Répertoire de travail** | ~/devops-exam |

---

## 🔗 Dépôts GitHub

| Dépôt | URL | Description |
|-------|-----|-------------|
| **Projet Principal** | https://github.com/Admiralphp/Deploiement-exam-2025 | Configuration complète (Ansible, Terraform, K8s, Scripts) |
| **CV Application** | https://github.com/Admiralphp/cv | Code source du CV + Jenkinsfile + Dockerfile |

---

## 🐳 Docker Hub

| Paramètre | Valeur |
|-----------|--------|
| **Username** | mohamedessid |
| **Image** | mohamedessid/cv-onepage |
| **Tags** | latest, <build-number> |

---

## 🌐 URLs d'Accès

| Service | URL | Port |
|---------|-----|------|
| **Jenkins** | http://10.174.154.25:8080 | 8080 |
| **CV (Terraform)** | http://10.174.154.25:8585 | 8585 |
| **CV (Kubernetes)** | http://10.174.154.25:30080 | 30080 |
| **Argo CD** | https://10.174.154.25:<NodePort> | Dynamique |

---

## 📝 Credentials

### Jenkins
- **URL:** http://10.174.154.25:8080
- **Mot de passe initial:** `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
- **Docker Hub Credential ID:** dockerhub-credentials

### Argo CD
- **Username:** admin
- **Mot de passe:** Voir fichier `~/argocd-credentials.txt` sur la VM
- **Commande pour récupérer:** 
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  ```

### Ansible
- **Inventaire:** ansible/inventory.ini
- **Méthode d'authentification:** Mot de passe (ansible_ssh_pass=123)
- **Sudo:** Mot de passe configuré (ansible_become_pass=123)

---

## 📦 Logiciels Installés (via Ansible)

| Logiciel | Version | Installation |
|----------|---------|--------------|
| **Docker** | Latest | ✅ Via Ansible |
| **Terraform** | 1.6.6 | ✅ Via Ansible |
| **Jenkins** | Latest | ✅ Via Ansible |
| **K3s** | Latest | ✅ Via script install-k3s.sh |
| **Argo CD** | Latest | ✅ Via script install-argocd.sh |
| **Grafana Agent** | Latest | ⏳ À installer via script |

---

## 🔧 Configuration Ansible

**Fichier inventory.ini:**
```ini
[devops_lab]
10.174.154.25 ansible_user=mohamed ansible_ssh_pass=123

[devops_lab:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_become_method=sudo
ansible_become_pass=123
```

**Rôles installés:**
1. ✅ system_update
2. ✅ docker
3. ✅ terraform
4. ✅ jenkins

---

## 🚀 Pipeline Jenkins

| Paramètre | Valeur |
|-----------|--------|
| **Nom du job** | cv-onepage-pipeline |
| **Type** | Pipeline from SCM |
| **Dépôt Git** | https://github.com/Admiralphp/cv.git |
| **Branche** | main |
| **Script Path** | Jenkinsfile |
| **Poll SCM** | H/5 * * * * (toutes les 5 minutes) |

**Étapes du pipeline:**
1. Préparation
2. Checkout du code
3. Vérification des fichiers
4. Build de l'image Docker
5. Test de l'image Docker
6. Login Docker Hub
7. Push vers Docker Hub
8. Nettoyage

---

## 📦 Terraform

| Paramètre | Valeur |
|-----------|--------|
| **Image Docker** | mohamedessid/cv-onepage:latest |
| **Nom du conteneur** | moncv |
| **Port externe** | 8585 |
| **Port interne** | 80 |
| **Restart policy** | unless-stopped |

---

## ☸️ Kubernetes (K3s)

### Deployment
- **Nom:** cv-onepage-deployment
- **Replicas:** 2
- **Image:** mohamedessid/cv-onepage:latest
- **Resources:**
  - Requests: 64Mi RAM, 100m CPU
  - Limits: 128Mi RAM, 200m CPU

### Service
- **Type:** NodePort
- **Port:** 80
- **NodePort:** 30080

### Argo CD Application
- **Nom:** cv-onepage-app
- **Dépôt:** https://github.com/Admiralphp/Deploiement-exam-2025.git
- **Path:** kubernetes
- **Sync Policy:** Automated (auto-heal, prune)

---

## 📊 Monitoring (Grafana Cloud)

| Paramètre | Configuration |
|-----------|---------------|
| **Prometheus URL** | À configurer |
| **Loki URL** | À configurer |
| **Username** | À configurer |
| **API Key** | À configurer |

**Métriques collectées:**
- CPU, RAM, Disk, Network (VM)
- Docker containers, images
- Kubernetes pods, nodes, deployments
- Logs système et applicatifs

---

## 📂 Structure des Fichiers

```
~/devops-exam/
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── playbook.yml
│   └── roles/
│       ├── system_update/
│       ├── docker/
│       ├── terraform/
│       └── jenkins/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── docker.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── kubernetes/
│   ├── deployment.yml
│   ├── service.yml
│   ├── namespace.yml
│   ├── argocd-application.yml
│   ├── ingress.yml
│   ├── configmap.yml
│   └── hpa.yml
└── scripts/
    ├── install-k3s.sh
    ├── install-argocd.sh
    ├── install-grafana-agent.sh
    ├── setup-ssh.sh
    └── setup-devops-lab.sh
```

---

## ✅ Checklist de Déploiement

### Partie I: Environnement
- [x] VM créée et configurée
- [x] SSH configuré
- [x] Git cloné sur la VM

### Partie II: Ansible
- [x] Ansible installé sur machine hôte
- [x] Playbook exécuté avec succès
- [x] Docker installé
- [x] Terraform installé
- [x] Jenkins installé

### Partie III: Jenkins
- [x] Jenkins accessible
- [x] Plugins installés
- [x] Credentials Docker Hub configurés
- [x] Pipeline créé
- [ ] Pipeline exécuté avec succès
- [ ] Image poussée sur Docker Hub

### Partie IV: Terraform
- [x] Terraform initialisé
- [x] Plan Terraform validé
- [ ] Apply Terraform exécuté
- [ ] Conteneur accessible

### Partie V: Kubernetes
- [x] K3s installé
- [x] Argo CD installé
- [x] Application déployée
- [ ] Application accessible via NodePort

### Partie VI: Monitoring
- [ ] Compte Grafana Cloud créé
- [ ] Grafana Agent installé
- [ ] Dashboards configurés
- [ ] Alertes configurées

---

## 🔍 Commandes de Vérification

```bash
# Vérifier Docker
docker --version
docker ps

# Vérifier Terraform
terraform --version
cd ~/devops-exam/terraform && terraform show

# Vérifier Jenkins
sudo systemctl status jenkins
curl http://10.174.154.25:8080

# Vérifier K3s
kubectl get nodes
kubectl get pods --all-namespaces

# Vérifier Argo CD
kubectl get pods -n argocd
kubectl get svc argocd-server -n argocd

# Vérifier l'application CV
kubectl get deployment cv-onepage-deployment
kubectl get svc cv-onepage-service
kubectl get pods -l app=cv-onepage

# Tester l'accès
curl http://10.174.154.25:8585  # Terraform
curl http://10.174.154.25:30080  # Kubernetes
```

---

**Dernière mise à jour:** 24 Novembre 2025
