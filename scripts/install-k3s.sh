#!/bin/bash

#############################################
# Script d'installation de K3s Single Node
# Pour Ubuntu Server 24.04
#############################################

set -e

echo "=========================================="
echo "Installation de K3s Single Node"
echo "=========================================="

# Vérifier si K3s est déjà installé
if command -v k3s &> /dev/null; then
    echo "K3s est déjà installé."
    k3s --version
    exit 0
fi

# Installation de K3s
echo "Téléchargement et installation de K3s..."
curl -sfL https://get.k3s.io | sh -

# Attendre que K3s soit prêt
echo "Attente du démarrage de K3s..."
sleep 15

# Vérifier l'installation
echo "Vérification de l'installation..."
sudo systemctl status k3s --no-pager

# Configuration de kubectl pour l'utilisateur courant
echo "Configuration de kubectl..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config

# Définir KUBECONFIG
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
export KUBECONFIG=~/.kube/config

# Vérifier que kubectl fonctionne
echo "Test de kubectl..."
kubectl get nodes
kubectl cluster-info

# Afficher les informations
echo ""
echo "=========================================="
echo "K3s installé avec succès!"
echo "=========================================="
echo "Version: $(k3s --version | head -n1)"
echo "Kubeconfig: ~/.kube/config"
echo ""
echo "Commandes utiles:"
echo "  kubectl get nodes"
echo "  kubectl get pods --all-namespaces"
echo "  sudo systemctl status k3s"
echo "=========================================="
