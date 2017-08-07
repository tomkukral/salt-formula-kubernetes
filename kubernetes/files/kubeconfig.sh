{%- from "kubernetes/map.jinja" import common with context -%}
#!/bin/bash

# server url
server="$(awk '/server/ { print $2 }' /etc/kubernetes/kubelet.kubeconfig)"

# certificates
cert="$(base64 /etc/kubernetes/ssl/kubelet-client.crt | sed 's/^/      /g')"
key="$(base64 /etc/kubernetes/ssl/kubelet-client.key | sed 's/^/      /g')"
ca="$(base64 /etc/kubernetes/ssl/ca-kubernetes.crt | sed 's/^/      /g')"
cluster="{{ common.addons.dns.domain }}"

echo "apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: |
${ca}
    server: ${server}
  name: ${cluster}
- cluster:
    server: http://localhost:8080
  name: local
contexts:
- context:
    cluster: ${cluster}
    user: admin-${cluster}
  name: ${cluster}
- context:
    cluster: local
    namespace: default
    user: ""
  name: local
current-context: ${cluster}
users:
- name: admin-${cluster}
  user:
    client-certificate-data: |
${cert}
    client-key-data: |
${key}
kind: Config
preferences: {}"
