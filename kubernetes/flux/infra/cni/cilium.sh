#!/bin/bash

helm upgrade \
    cilium \
    cilium/cilium \
    --version 1.15.7 \
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
    --set hubble.relay.enabled=true \
    --set hubble.ui.enabled=true \
    --set l2announcements.enabled=true \
    --set l2announcements.leaseDuration="3s" \
    --set l2announcements.leaseRenewDeadline="1s" \
    --set l2announcements.leaseRetryPeriod="500ms" \
    --set k8sClientRateLimit.qps={QPS} \
    --set k8sClientRateLimit.burst={BURST}