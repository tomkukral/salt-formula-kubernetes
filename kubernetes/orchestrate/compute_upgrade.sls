{%- set node_name = salt['pillar.get']('event_originator') %}
{%- set short_name = node_name.split('.')[0] %}

cordon_node:
  salt.function:
    - name: cmd.run
    - tgt: '*01* and I@kubernetes:master'
    - tgt_type: compound
    - arg:
      - kubectl cordon {{ short_name }}

drain_node:
  salt.function:
    - name: cmd.run
    - tgt: '*01* and I@kubernetes:master'
    - tgt_type: compound
    - arg:
      - kubectl drain --force --ignore-daemonsets --grace-period 100 --timeout 120s --delete-local-data {{ short_name }}
    - require:
      - salt: cordon_node

cert_state:
  salt.state:
    - tgt: '{{ node_name }}'
    - sls: salt.minion.cert
    - queue: True
    - require:
      - salt: drain_node

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

uncordon_node:
  salt.function:
    - name: cmd.run
    - tgt: '*01* and I@kubernetes:master'
    - tgt_type: compound
    - arg:
      - kubectl uncordon {{ short_name }}
    - require:
      - salt: pool_state
