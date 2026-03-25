#!/bin/bash
set -e

echo "Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "Installing ArgoCD..."
kubectl apply -n argocd -f install.yml
# https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD server..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

echo "Installing ArgoCD Application..."
kubectl apply -f application.yml

echo "Installing Image Updater..."
kubectl apply -f image-updater.yml

# helm repo add argo https://argoproj.github.io/argo-helm
# helm repo update
# helm install argocd-image-updater argo/argocd-image-updater -n argocd

echo "Installing External Secrets Operator for creating k8s secrets from azure keyvault secrets"
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace

echo "Bootstrap completed."