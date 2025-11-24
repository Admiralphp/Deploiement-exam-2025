# Kubernetes Manifests

Ce dossier contient tous les manifests Kubernetes pour déployer l'application CV One Page sur K3s avec Argo CD.

## Structure des fichiers

```
kubernetes/
├── namespace.yml            # Namespace pour Argo CD
├── deployment.yml           # Deployment avec 2 replicas
├── service.yml              # Service NodePort
├── ingress.yml              # Ingress (optionnel)
├── configmap.yml            # Configuration Nginx
├── hpa.yml                  # Horizontal Pod Autoscaler
└── argocd-application.yml   # Application Argo CD
```

## Ordre de déploiement manuel

```bash
# 1. Appliquer le namespace
kubectl apply -f namespace.yml

# 2. Appliquer le ConfigMap
kubectl apply -f configmap.yml

# 3. Appliquer le Deployment
kubectl apply -f deployment.yml

# 4. Appliquer le Service
kubectl apply -f service.yml

# 5. Appliquer le HPA (optionnel)
kubectl apply -f hpa.yml

# 6. Appliquer l'Ingress (optionnel)
kubectl apply -f ingress.yml
```

## Déploiement avec Argo CD

```bash
# 1. Installer Argo CD sur K3s
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Attendre que Argo CD soit prêt
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# 3. Obtenir le mot de passe admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 4. Port-forward pour accéder à l'interface Argo CD
kubectl port-forward svc/argocd-server -n argocd 8080:443

# 5. Déployer l'application avec Argo CD
kubectl apply -f argocd-application.yml
```

## Vérification du déploiement

```bash
# Vérifier les pods
kubectl get pods -l app=cv-onepage

# Vérifier le service
kubectl get svc cv-onepage-service

# Vérifier le deployment
kubectl get deployment cv-onepage-deployment

# Obtenir les logs
kubectl logs -l app=cv-onepage --tail=50

# Décrire un pod
kubectl describe pod -l app=cv-onepage
```

## Accès à l'application

```bash
# Via NodePort
http://<IP_VM>:30080

# Via port-forward
kubectl port-forward svc/cv-onepage-service 8080:80
# Puis accéder à http://localhost:8080
```

## Mise à jour de l'application

Avec Argo CD configuré en mode automatique, toute modification dans le dépôt Git sera automatiquement synchronisée.

Pour forcer une synchronisation manuelle :

```bash
# Via CLI Argo CD
argocd app sync cv-onepage-app

# Via kubectl
kubectl -n argocd patch app cv-onepage-app -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}' --type merge
```

## Monitoring

```bash
# Surveiller les replicas
kubectl get hpa cv-onepage-hpa --watch

# Surveiller les événements
kubectl get events --sort-by='.lastTimestamp' | grep cv-onepage

# Métriques des pods
kubectl top pods -l app=cv-onepage
```

## Nettoyage

```bash
# Supprimer l'application Argo CD
kubectl delete -f argocd-application.yml

# Supprimer toutes les ressources
kubectl delete -f .

# Ou supprimer par label
kubectl delete all -l app=cv-onepage
```
