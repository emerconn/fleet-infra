#!/bin/bash

cilium_version=1.18.1
prometheus_service_monitor_enabled=false

helm repo add cilium https://helm.cilium.io/
helm repo update

helm upgrade \
    cilium \
    cilium/cilium \
    --version $cilium_version \
    --install \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=true \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup \
    --set k8sServiceHost=localhost \
    --set k8sServicePort=7445 \
    --set prometheus.enabled=true \
    --set prometheus.serviceMonitor.enabled=$prometheus_service_monitor_enabled \
    --set operator.prometheus.enabled=true \
    --set operator.prometheus.serviceMonitor.enabled=$prometheus_service_monitor_enabled \
    --set hubble.enabled=true \
    --set hubble.relay.enabled=true \
    --set hubble.relay.prometheus.enabled=true \
    --set hubble.relay.prometheus.serviceMonitor.enabled=$prometheus_service_monitor_enabled \
    --set hubble.ui.enabled=true \
    --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}" \
    --set hubble.metrics.enableOpenMetrics=true \
    --set hubble.metrics.prometheus.enabled=true \
    --set hubble.metrics.prometheus.serviceMonitor.enabled=$prometheus_service_monitor_enabled \
    --set envoy.enabled=true \
    --set envoy.initialFetchTimeoutSeconds=30 \
    --set envoy.prometheus.enabled=true \
    --set envoy.prometheus.serviceMonitor.enabled=$prometheus_service_monitor_enabled \
    --set ingressController.enabled=true \
    --set gatewayAPI.enabled=true \
    --set l2announcements.enabled=true \
    --set l2announcements.leaseDuration="3s" \
    --set l2announcements.leaseRenewDeadline="1s" \
    --set l2announcements.leaseRetryPeriod="500ms"
