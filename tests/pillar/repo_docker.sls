linux:
  system:
    enabled: true
    repo:
      docker:
        source: "deb https://apt.dockerproject.org/repo ubuntu-{{ grains.get('oscodename') }} main"
        architectures: amd64
        key_id: 58118E89F3A912897C070ADBF76221572C52609D
        key_server: hkp://p80.pool.sks-keyservers.net:80
    package:
      python-docker:
        version: latest
