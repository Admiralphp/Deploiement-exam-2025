#!/bin/bash

#############################################
# Script de génération de clés SSH
# Pour accès à la VM DEVOPS-LAB
#############################################

set -e

echo "=========================================="
echo "Génération de clés SSH"
echo "=========================================="

SSH_KEY_PATH="$HOME/.ssh/id_rsa_devops"
SSH_KEY_COMMENT="devops-lab-key"

# Vérifier si la clé existe déjà
if [ -f "$SSH_KEY_PATH" ]; then
    echo "Une clé SSH existe déjà à $SSH_KEY_PATH"
    read -p "Voulez-vous la régénérer? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Opération annulée."
        exit 0
    fi
    rm -f "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"
fi

# Créer le répertoire .ssh s'il n'existe pas
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Générer la paire de clés SSH
echo "Génération de la paire de clés SSH..."
ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -C "$SSH_KEY_COMMENT" -N ""

# Définir les permissions appropriées
chmod 600 "$SSH_KEY_PATH"
chmod 644 "$SSH_KEY_PATH.pub"

# Afficher la clé publique
echo ""
echo "=========================================="
echo "Clé SSH générée avec succès!"
echo "=========================================="
echo "Clé privée: $SSH_KEY_PATH"
echo "Clé publique: $SSH_KEY_PATH.pub"
echo ""
echo "Contenu de la clé publique:"
echo "=========================================="
cat "$SSH_KEY_PATH.pub"
echo "=========================================="
echo ""
echo "Étapes suivantes:"
echo "1. Copier la clé publique sur la VM:"
echo "   ssh-copy-id -i $SSH_KEY_PATH.pub user@VM_IP"
echo ""
echo "2. Ou manuellement:"
echo "   cat $SSH_KEY_PATH.pub | ssh user@VM_IP 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'"
echo ""
echo "3. Se connecter à la VM:"
echo "   ssh -i $SSH_KEY_PATH user@VM_IP"
echo ""
echo "4. Pour Ansible, mettre à jour inventory.ini:"
echo "   ansible_ssh_private_key_file=$SSH_KEY_PATH"
echo "=========================================="

# Sauvegarder les informations
cat > ~/ssh-key-info.txt <<EOF
SSH Key Information
===================
Private Key: $SSH_KEY_PATH
Public Key: $SSH_KEY_PATH.pub
Comment: $SSH_KEY_COMMENT
Generated: $(date)

Public Key Content:
$(cat "$SSH_KEY_PATH.pub")
EOF

chmod 600 ~/ssh-key-info.txt
echo "Informations sauvegardées dans ~/ssh-key-info.txt"
