#!/bin/bash

#############################################
# Script d'installation de Argo CD sur K3s
# Pour Ubuntu Server 24.04
#############################################

set -e

echo "=========================================="
echo "Installation de Argo CD sur K3s"
echo "=========================================="

# Vérifier que kubectl est disponible
if ! command -v kubectl &> /dev/null; then
    echo "Erreur: kubectl n'est pas installé!"
    exit 1
fi

# Créer le namespace argocd
echo "Création du namespace argocd..."
kubectl create namespace argocd || echo "Namespace argocd existe déjà"

# Installer Argo CD
echo "Installation de Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Attendre que les pods Argo CD soient prêts
echo "Attente du démarrage de Argo CD (cela peut prendre quelques minutes)..."
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

# Récupérer le mot de passe initial
echo "Récupération du mot de passe admin..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Installer Argo CD CLI
echo "Installation de Argo CD CLI..."
if ! command -v argocd &> /dev/null; then
    curl -sSL -o /tmp/argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 /tmp/argocd-linux-amd64 /usr/local/bin/argocd
    rm /tmp/argocd-linux-amd64
fi

# Changer le service en NodePort pour un accès facile
echo "Configuration du service Argo CD en NodePort..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Obtenir le NodePort
ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[0].nodePort}')
VM_IP=$(hostname -I | awk '{print $1}')

# Afficher les informations
echo ""
echo "=========================================="
echo "Argo CD installé avec succès!"
echo "=========================================="
echo "URL: https://$VM_IP:$ARGOCD_PORT"
echo "Utilisateur: admin"
echo "Mot de passe: $ARGOCD_PASSWORD"
echo ""
echo "Pour accéder via port-forward:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  URL: https://localhost:8080"
echo ""
echo "Pour se connecter avec CLI:"
echo "  argocd login $VM_IP:$ARGOCD_PORT --insecure"
echo "  Username: admin"
echo "  Password: $ARGOCD_PASSWORD"
echo ""
echo "Commandes utiles:"
echo "  kubectl get pods -n argocd"
echo "  argocd app list"
echo "  argocd app get <app-name>"
echo "=========================================="

# Sauvegarder les credentials
echo "Sauvegarde des credentials dans ~/argocd-credentials.txt"
cat > ~/argocd-credentials.txt <<EOF
Argo CD Credentials
===================
URL: https://$VM_IP:$ARGOCD_PORT
Username: admin
Password: $ARGOCD_PASSWORD
Date: $(date)
EOF

chmod 600 ~/argocd-credentials.txt
echo "Credentials sauvegardés dans ~/argocd-credentials.txt"
