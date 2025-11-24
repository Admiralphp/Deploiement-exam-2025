#!/bin/bash

#############################################
# Script complet de configuration DevOps Lab
# Exécute tous les scripts d'installation
#############################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Configuration complète DEVOPS-LAB"
echo "=========================================="
echo "Date: $(date)"
echo "Utilisateur: $(whoami)"
echo "Hostname: $(hostname)"
echo "=========================================="
echo ""

# Fonction pour exécuter un script
run_script() {
    local script_name=$1
    local script_path="$SCRIPT_DIR/$script_name"
    
    echo ""
    echo ">>> Exécution: $script_name"
    echo "-------------------------------------------"
    
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        bash "$script_path"
        echo "-------------------------------------------"
        echo "✓ $script_name terminé avec succès"
    else
        echo "⚠ Script non trouvé: $script_path"
        return 1
    fi
}

# Menu interactif
show_menu() {
    echo ""
    echo "Que souhaitez-vous installer?"
    echo "1) Tout installer (recommandé)"
    echo "2) K3s uniquement"
    echo "3) Argo CD uniquement"
    echo "4) Grafana Agent uniquement"
    echo "5) Configurer SSH uniquement"
    echo "6) Quitter"
    echo ""
    read -p "Votre choix (1-6): " choice
    
    case $choice in
        1)
            echo "Installation complète..."
            run_script "setup-ssh.sh"
            run_script "install-k3s.sh"
            run_script "install-argocd.sh"
            run_script "install-grafana-agent.sh"
            ;;
        2)
            run_script "install-k3s.sh"
            ;;
        3)
            run_script "install-argocd.sh"
            ;;
        4)
            run_script "install-grafana-agent.sh"
            ;;
        5)
            run_script "setup-ssh.sh"
            ;;
        6)
            echo "Au revoir!"
            exit 0
            ;;
        *)
            echo "Choix invalide!"
            show_menu
            ;;
    esac
}

# Vérifier si on est sur Ubuntu
if [ ! -f /etc/os-release ]; then
    echo "Erreur: Impossible de détecter le système d'exploitation"
    exit 1
fi

source /etc/os-release
if [ "$ID" != "ubuntu" ]; then
    echo "Avertissement: Ce script est conçu pour Ubuntu Server"
    read -p "Continuer quand même? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Afficher le menu
show_menu

# Résumé final
echo ""
echo "=========================================="
echo "Configuration terminée!"
echo "=========================================="
echo "Date de fin: $(date)"
echo ""
echo "Services installés:"
echo "-------------------------------------------"
[ -f ~/.kube/config ] && echo "✓ K3s" || echo "✗ K3s"
kubectl get ns argocd &>/dev/null && echo "✓ Argo CD" || echo "✗ Argo CD"
systemctl is-active --quiet grafana-agent && echo "✓ Grafana Agent" || echo "✗ Grafana Agent"
echo "=========================================="
echo ""
echo "Fichiers de configuration créés:"
[ -f ~/argocd-credentials.txt ] && echo "  - ~/argocd-credentials.txt (Argo CD)"
[ -f ~/ssh-key-info.txt ] && echo "  - ~/ssh-key-info.txt (SSH Keys)"
echo ""
echo "Prochaines étapes:"
echo "1. Vérifier les services: sudo systemctl status"
echo "2. Configurer Grafana Cloud avec vos credentials"
echo "3. Déployer votre application avec Argo CD"
echo "4. Consulter le README.md pour plus d'informations"
echo "=========================================="
