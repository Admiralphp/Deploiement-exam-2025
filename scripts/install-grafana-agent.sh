#!/bin/bash

#############################################
# Script d'installation de Grafana Agent
# Pour monitoring avec Grafana Cloud
#############################################

set -e

echo "=========================================="
echo "Installation de Grafana Agent"
echo "=========================================="

# Variables à configurer (remplacer par vos valeurs Grafana Cloud)
GRAFANA_CLOUD_URL="https://prometheus-prod-XX-XX.grafana.net/api/prom/push"
GRAFANA_CLOUD_USERNAME="XXXXX"
GRAFANA_CLOUD_API_KEY="YOUR_API_KEY"
GRAFANA_LOKI_URL="https://logs-prod-XX.grafana.net/loki/api/v1/push"

# Vérifier si Grafana Agent est déjà installé
if systemctl is-active --quiet grafana-agent; then
    echo "Grafana Agent est déjà installé et en cours d'exécution."
    exit 0
fi

# Ajouter le dépôt Grafana
echo "Ajout du dépôt Grafana..."
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Mettre à jour et installer
echo "Installation de Grafana Agent..."
sudo apt-get update
sudo apt-get install -y grafana-agent

# Créer la configuration pour Grafana Agent
echo "Configuration de Grafana Agent..."
sudo tee /etc/grafana-agent.yaml > /dev/null <<EOF
server:
  log_level: info

metrics:
  global:
    scrape_interval: 60s
    remote_write:
      - url: ${GRAFANA_CLOUD_URL}
        basic_auth:
          username: ${GRAFANA_CLOUD_USERNAME}
          password: ${GRAFANA_CLOUD_API_KEY}

  configs:
    - name: agent
      scrape_configs:
        # Monitoring du système (Node Exporter)
        - job_name: 'node'
          static_configs:
            - targets: ['localhost:9100']
              labels:
                instance: 'devops-lab'
                environment: 'production'

        # Monitoring de Docker
        - job_name: 'docker'
          static_configs:
            - targets: ['localhost:9323']
              labels:
                instance: 'devops-lab-docker'

        # Monitoring de K3s
        - job_name: 'k3s'
          static_configs:
            - targets: ['localhost:10250']
              labels:
                instance: 'devops-lab-k3s'

logs:
  configs:
    - name: default
      clients:
        - url: ${GRAFANA_LOKI_URL}
          basic_auth:
            username: ${GRAFANA_CLOUD_USERNAME}
            password: ${GRAFANA_CLOUD_API_KEY}
      positions:
        filename: /tmp/positions.yaml
      scrape_configs:
        # Logs système
        - job_name: system
          static_configs:
            - targets:
                - localhost
              labels:
                job: varlogs
                host: devops-lab
                __path__: /var/log/*.log

        # Logs Docker
        - job_name: docker
          static_configs:
            - targets:
                - localhost
              labels:
                job: docker
                host: devops-lab
                __path__: /var/lib/docker/containers/*/*.log

integrations:
  node_exporter:
    enabled: true
    enable_collectors:
      - cpu
      - diskstats
      - filesystem
      - loadavg
      - meminfo
      - netdev
      - netstat
      - uname
EOF

# Démarrer et activer Grafana Agent
echo "Démarrage de Grafana Agent..."
sudo systemctl enable grafana-agent
sudo systemctl restart grafana-agent

# Vérifier le statut
sleep 3
sudo systemctl status grafana-agent --no-pager

echo ""
echo "=========================================="
echo "Grafana Agent installé avec succès!"
echo "=========================================="
echo "Configuration: /etc/grafana-agent.yaml"
echo "Service: grafana-agent"
echo ""
echo "Commandes utiles:"
echo "  sudo systemctl status grafana-agent"
echo "  sudo journalctl -u grafana-agent -f"
echo "  sudo systemctl restart grafana-agent"
echo ""
echo "N'oubliez pas de:"
echo "1. Remplacer les variables dans /etc/grafana-agent.yaml"
echo "2. Configurer vos dashboards dans Grafana Cloud"
echo "=========================================="
