#!/bin/bash

set -e

echo "Installing ArgoCD..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace

kubectl apply -f services.yml
kubectl apply -f image-updater.yml

echo "Installing External Secrets Operator(ESO)"
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace

kubectl apply -f ServiceAccount.yml
kubectl apply -f SecretStore.yml
kubectl apply -f infra-git-secret
kubectl apply -f ghcr-secret.yml

echo "Installing ingress-nginx"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
kubectl create deployment nginx --image=nginx -n ingress-nginx

openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout tls.key \
-out tls.crt \
-subj "/CN=*.ufukcetinkaya.net/O=dev"

kubectl create secret tls api-tls --cert=tls.crt --key=tls.key -n edonusum

echo "Bootstrap completed."