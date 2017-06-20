kubernetes:
  common:
    network:
      engine: none
    hyperkube:
      image: hyperkube-amd64:v1.5.0-beta.3-1
  pool:
    enabled: true
    version: v1.2.0
    host:
      name: ${linux:system:name}
    apiserver:
      host: 127.0.0.1
      insecure:
        enabled: True
      members:
        - host: 127.0.0.1
        - host: 127.0.0.1
        - host: 127.0.0.1
    address: 0.0.0.0
    cluster_dns: 10.254.0.10
    cluster_domain: cluster.local
    kubelet:
      config: /etc/kubernetes/manifests
      allow_privileged: True
      frequency: 5s
    token:
      kubelet: 7bN5hJ9JD4fKjnFTkUKsvVNfuyEddw3r
      kube_proxy: DFvQ8GelB7afH3wClC9romaMPhquyyEe
    ca: kubernetes
    network:
      engine: opencontrail
      version: 4.0
      config:
        api:
          address: 127.0.0.1
    hyperkube:
      hash: hnsj0XqABgrSww7Nqo7UVTSZLJUt2XRd
