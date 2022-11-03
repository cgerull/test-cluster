#!/bin/bash
#
# Install Flux components on local k3d cluster
#
export GITHUB_USER=cgerull
export GITHUB_TOKEN=***************
#
flux bootstrap github \
    --owner="$GITHUB_USER" \
    --personal \
    --repository=flux \
    --branch=main \
    --path=./clusters/k3d-dev
#
#
# Install Aquasecurity operator
#
kubectl create ns starboard-system
#
flux create source helm starboard-operator \
    --url https://aquasecurity.github.io/helm-charts \
    --namespace starboard-system
#
flux create helmrelease starboard-operator \
    --chart starboard-operator \
    --source HelmRepository/starboard-operator \
    --chart-version 0.10.8 \
    --namespace starboard-system
#
#
# Install Prometheus Grafana stack
#
kubectl create ns monitoring
#
flux create source git flux-monitoring \
  --interval=30m \
  --url=https://github.com/fluxcd/flux2 \
  --branch=main
#
flux create kustomization kube-prometheus-stack \
  --interval=1h \
  --prune \
  --source=flux-monitoring \
  --path="./manifests/monitoring/kube-prometheus-stack" \
  --health-check-timeout=5m \
  --wait
#
# flux create kustomization loki-stack \
#   --depends-on=kube-prometheus-stack \
#   --interval=1h \
#   --prune \
#   --source=flux-monitoring \
#   --path="./manifests/monitoring/loki-stack" \
#   --health-check-timeout=5m \
#   --wait
#
flux create kustomization monitoring-config \
  --depends-on=kube-prometheus-stack \
  --interval=1h \
  --prune=true \
  --source=flux-monitoring \
  --path="./manifests/monitoring/monitoring-config" \
  --health-check-timeout=1m \
  --wait
#
# Install Sonarqube from helm
# Running only on Intel / AMD amd64 platform
# #
# kubectl create ns sonarqube
# #
# flux create source helm sonarqube \
#     --url https://SonarSource.github.io/helm-chart-sonarqube \
#     --namespace sonarqube
# #
# flux create helmrelease sonarqube \
#     --chart sonarqube \
#     --source HelmRepository/sonarqube \
#     --chart-version 5.0.6+370 \
#     --namespace sonarqube
# #
#
#
# Install an app to deploy
#
kubectl create ns testserver
#
flux create source git testserver \
    --url=https://github.com/cgerull/deploy-test-server.git \
    --branch=main
#
flux create kustomization testserver \
  --target-namespace=testserver \
  --source=testserver \
  --path="./kubernetes/dev-local/" \
  --prune=true \
  --interval=5m

#
flux create source git testcluster \
    --url=https://github.com/cgerull/deploy-test-cluster.git \
    --branch=main
#
flux create kustomization mariadb \
  --target-namespace=mariadb \
  --source=testclusterr \
  --path="./kubernetes/dev-local/" \
  --prune=true \
  --interval=5m