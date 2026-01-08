## Mini Projet
Ce repository contient l'ensemble des scripts, playbooks Ansible et configurations nécessaires au déploiement automatisé d'infrastructures cloud sur Microsoft Azure dans le cadre de projets DevOps.
Objectifs
## Vue d’ensemble du projet
Automatisation complète du provisionnement d'infrastructure (Infrastructure as Code)
Déploiement d'environnements de préproduction et production
Gestion de conteneurs avec Docker et Kubernetes (AKS)
Mise en place de solutions de monitoring et sécurisation des services
Prérequis
# Logiciels requis
# Système d'exploitation
Ubuntu 22.04 LTS (machine d'administration)
# Outils
- Azure CLI
- kubectl
- Helm pour l'installation de prometheus 
- Git
# Configuration
- Ansible >= 2.9
- Python 3.8+
- Docker

## 1. Déploiement VM Ubuntu avec Docker et Nginx

## Compte Azure

Compte Azure actif avec abonnement Pay-As-You-Go
Service Principal avec rôle Contributor

# Clés SSH

Script Bash automatisé pour créer une VM Ubuntu 22.04 avec Docker et Nginx sur Azure.
Ressources créées :

Groupe de ressources Azure (devops-deploy-vm-rg)
VM Ubuntu Server (Standard_B1s)
Installation Docker automatisée
Conteneur Nginx sur port 80

Script : deploy_vm_nginx_azure.sh
## 2. Provisionnement avec Ansible (Nginx + PostgreSQL)
Déploiement Infrastructure as Code avec Ansible pour provisionner un serveur Ubuntu avec services Nginx et PostgreSQL.
Composants :

Réseau virtuel (VNet) avec sous-réseau isolé
VM Ubuntu 22.04 LTS (Standard_B2s)
Nginx (reverse proxy)
PostgreSQL 15

Playbooks : creation_vm.yml, main.yml, site.yml

# Application Nextcloud Sécurisée
Déploiement de Nextcloud avec terminaison TLS/SSL via Nginx reverse proxy.
Fonctionnalités :

Certificat SSL auto-signé
Configuration HTTPS (port 443)
Politiques de sécurité renforcées (TLS 1.2/1.3)
Network Security Groups (NSG) configurés

# Cluster Kubernetes (AKS)
Environnement de production avec Azure Kubernetes Service pour héberger Nextcloud, PostgreSQL et Nginx.
Infrastructure :

Cluster AKS avec 2 nœuds (Standard_B2ms)
Azure Container Registry (ACR)
Déploiements via manifests Kubernetes
Load Balancer Azure avec IP publique

Playbooks : creation_aks.yml
Manifests : postgre-deploy.yml, nextcloud-deploy.yml

# CI/CD avec GitHub Actions
Pipeline de déploiement automatisé pour environnement de préproduction.
Workflow : .github/workflows

Déclenchement automatique sur push (branche main)
Provisionnement des ressources Azure via Ansible
Gestion des secrets via GitHub Secrets

Workflow : .github/workflows/azure-preprod-deploy.yml
## Monitoring avec Prometheus et Grafana
Métriques collectées :
Utilisation CPU/RAM des nœuds
État des pods et deployments
Métriques système via node-exporter

### Configuration clés
# Installation Ansible deouis une machine administration 
# Installation Ansible
sudo apt update
sudo apt install -y ansible

# Installation collection Azure
ansible-galaxy collection install azure.azcollection

# Installation dépendances Python
python3 -m venv ~/.venvs/ansible-azure
source ~/.venvs/ansible-azure/bin/activate
pip install "ansible[azure]"

# Configuration des variables d'environnement
export AZURE_CLIENT_ID=""
export AZURE_SECRET=""
export AZURE_TENANT=""
export AZURE_SUBSCRIPTION_ID=""

# Configuration kubectl pour AKS
# Récupérer les credentials du cluster
az aks get-credentials --resource-group devops-deploy-vm-rg \
  --name dp-aks-cluster

# Vérification de la connexion
kubectl get nodes

Déploiement VM avec script Bash
# Les droits d'exécution
chmod +x deploy_vm_nginx_azure.sh

# Exécution du script
./deploy_vm_nginx_azure.sh
Déploiement avec Ansible
bash# Exécuter le playbook de création VM
ansible-playbook creation_vm.yml -vvv

# Installation Nginx pour nextcloud
ansible-playbook site.yml
Déploiement cluster AKS
# Créer le cluster AKS
ansible-playbook creation_aks.yml \
  -e ansible_python_interpreter=~/.venvs/ansible-azure/bin/python -vvv

# Déployement PostgreSQL
kubectl apply -f postgre-deploy.yml

# Déployement Nextcloud
kubectl apply -f nextcloud-deploy.yml

# Vérification des déploiements
kubectl get pods
kubectl get services
## Déploiement via GitHub Actions
# Pousser vers le dépôt
git add .
git commit
git push origin main
## Monitoring
# Installation Prometheus sur AKS
# Ajout du repository Helm
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
helm repo update

# Installation des exporters
helm install kube-prom-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set prometheus.enabled=false \
  --set grafana.enabled=false
# Exposition des métriques
# Exposition kube-state-metrics
kubectl edit svc kube-prom-stack-kube-state-metrics -n monitoring
# Changer type: ClusterIP en type: LoadBalancer

# Exposer node-exporter
kubectl edit svc kube-prom-stack-prometheus-node-exporter -n monitoring

# Vérifier les IP externes
kubectl get svc -n monitoring
## Configuration Prometheus (local)
# Ajouter les jobs dans /etc/prometheus/prometheus.yml :
yaml- job_name: "kube-state-metrics-aks"
  scrape_interval: 15s
  static_configs:
    - targets: ["<MY-IP_EXTERNE>:8080"]

- job_name: "node-exporter-aks"
  scrape_interval: 15s
  static_configs:
    - targets: ["<MY-IP_EXTERNE>:9100"]
Redémarrage Prometheus :
systemctl restart prometheus.service
# Dashboards Grafana
# Importation les dashboards depuis grafana-dashboards-kubernetes :

ID 19105 : k8s-addons-prometheus
ID 15759 : k8s-views-nodes
ID 15760 : k8s-views-pods

## Sécurisation d'accès à NextCloud
# Certificats SSL
Génération d'un certificat auto-signé :
mkdir -p nginx-certs
openssl req -x509 -nodes -days 365 \
  -newkey rsa:4096 \
  -keyout nginx-certs/selfsigned.key \
  -out nginx-certs/selfsigned.crt \
  -subj "/CN=localhost"
## Configuration NSG
# Règles de sécurité sur Azure :
# Autoriser SSH depuis IP d'administration
az network nsg rule create \
  --resource-group devops-deploy-vm-rg \
  --nsg-name aks-cluster-nsg \
  --name autoriser-ssh-admin \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes <IP> \
  --destination-port-ranges 22

# Autoriser HTTP depuis IP d'administration
az network nsg rule create \
  --resource-group devops-deploy-vm-rg \
  --nsg-name aks-cluster-nsg \
  --name autoriser-http-depuis-admin \
  --priority 120 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes <IP> \
  --destination-port-ranges 80
# Configuration Nginx SSL
nginxserver {
    listen 443 ssl http2;
    ssl_certificate /etc/nginx/ssl/nextcloud.crt;
    ssl_certificate_key /etc/nginx/ssl/nextcloud.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains" always;
    
    location / {
        proxy_pass http://nextcloud-container:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    
