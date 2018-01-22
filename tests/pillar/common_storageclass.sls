kubernetes:
  master:
    enabled: true
    admin:
      password: password
      username: admin
    version: v1.2.4
    host:
      name: node040
    etcd:
      members:
      - host: 10.0.175.100
        name: node040
    namespace:
      kube-system:
        enabled: true
    network:
      engine: calico
      hash: fb5e30ebe6154911a66ec3fb5f1195b2
      private_ip_range: 10.150.0.0/16
      version: v0.19.0
      etcd:
        members:
        - host: 127.0.0.1
          port: 4001
        - host: 127.0.0.1
          port: 4001
        - host: 127.0.0.1
          port: 4001
    service_addresses: 10.254.0.0/16
    storage:
      engine: glusterfs
      members:
      - host: 10.0.175.101
        port: 24007
      - host: 10.0.175.102
        port: 24007
      - host: 10.0.175.103
        port: 24007
      port: 24007
    registry:
        host: tcpcloud
  common:
    network:
      engine: none
    addons:
      storageclass:
        nfs_elastic_1:
          enabled: True
          provisioner: nfs
          spec:
            name: elastic_data
            nfs:
              server: 10.0.0.1
              path: /exported_path/elastic01
        nfs_elastic_2:
          enabled: True
          provisioner: nfs
          spec:
            name: elastic_data
            nfs:
              server: 10.0.0.1
              path: /exported_path/elastic02
        nfs_influx:
          name: influx01
          enabled: False
          provisioner: nfs
          spec:
            name: influx
            nfs:
              server: 10.0.0.1
              path: /exported_path/inlfux01
    monitoring:
      backend: prometheus
