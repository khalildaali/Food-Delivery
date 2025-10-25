#!/bin/bash

# Fonction pour afficher les messages avec timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Vérifier si minikube est installé
if ! command -v minikube &> /dev/null; then
    log "Installation de minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-windows-amd64.exe
    mv minikube-windows-amd64.exe /usr/local/bin/minikube
fi

# Vérifier si kubectl est installé
if ! command -v kubectl &> /dev/null; then
    log "Installation de kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/windows/amd64/kubectl.exe"
    mv kubectl.exe /usr/local/bin/kubectl
fi

# Démarrer le cluster minikube
log "Démarrage du cluster minikube..."
minikube start --nodes=3 --driver=docker --cpus=2 --memory=2048

# Attendre que les nœuds soient prêts
log "Attente de la disponibilité des nœuds..."
kubectl wait --for=condition=ready node --all --timeout=300s

# Créer le namespace
log "Création du namespace food-delivery..."
kubectl create namespace food-delivery

# Appliquer les configurations
log "Application des configurations Kubernetes..."
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/mongodb.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

# Installation de metrics-server pour HPA
log "Installation de metrics-server..."
minikube addons enable metrics-server

# Attendre que tous les pods soient prêts
log "Attente du démarrage des pods..."
kubectl wait --namespace food-delivery --for=condition=ready pod --all --timeout=300s

# Afficher les informations du cluster
log "État du cluster :"
kubectl get nodes -o wide
log "Services déployés :"
kubectl get services -n food-delivery
log "Pods en cours d'exécution :"
kubectl get pods -n food-delivery
log "HPAs configurés :"
kubectl get hpa -n food-delivery

# Instructions pour accéder à l'application
log "Pour accéder à l'application :"
log "1. Frontend : $(minikube service frontend -n food-delivery --url)"
log "2. Backend : $(minikube service backend -n food-delivery --url)"

log "Déploiement terminé avec succès!"