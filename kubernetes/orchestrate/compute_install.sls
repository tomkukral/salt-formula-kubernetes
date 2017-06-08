{%- set node_name = salt['pillar.get']('event_originator') %}

cert_state:
  salt.state:
    - tgt: '{{ node_name }}'
    - sls: salt.minion.cert
    - queue: True

docker_state:
  salt.state:
    - tgt: '{{ node_name }}'
    - sls: docker.host
    - queue: True
    - require:
      - salt: cert_state

pool_state:
  salt.state:
    - tgt: '{{ node_name }}'
    - sls: kubernetes.pool
    - queue: True
    - require:
      - salt: docker_state
