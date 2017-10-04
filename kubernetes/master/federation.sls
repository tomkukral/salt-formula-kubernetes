{%- from "kubernetes/map.jinja" import master with context %}
{%- from "kubernetes/map.jinja" import common with context %}
{%- if master.enabled %}

extract_kubernetes_client:
  archive.extracted:
    - name: /tmp/kubernetes-client
    - source: {{ master.federation.source }}
    {%- if master.federation.get('hash') %}
    - source_hash: sha256={{ master.federation.hash }}
    {%- endif %}
    - tar_options: xzf
    - archive_format: tar
    - keep: true
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

/usr/bin/kubefed:
  file.managed:
  - source: /tmp/kubernetes-client/kubernetes/client/bin/kubefed
  - mode: 755
  - owner: root
  - group: root
  - require:
    - archive: extract_kubernetes_client

/etc/kubernetes/federation/federation.kubeconfig:
  file.copy:
  - source: /etc/kubernetes/admin-kube-config
  - force: false
  - mode: 0700
  - owner: root
  - group: root
  - dir_mode: 755
  - makedirs: True

#Set server to apiserver VIP instead of localhost to be reached from pod net
federation_kubeconfig_replace_server:
  file.replace:
  - name: /etc/kubernetes/federation/federation.kubeconfig
  - repl: "server: https://{{ master.apiserver.vip_address }}:{{ master.apiserver.secure_port }}"
  - pattern: "server: http://127.0.0.1:{{ master.apiserver.insecure_port }}"
  - count: 1
  - show_changes: True

/etc/kubernetes/federation/dns.conf:
  file.managed:
  - source: salt://kubernetes/files/federation/{{ master.federation.dns_provider }}.conf
  - template: jinja
  - user: root
  - group: root
  - mode: 644
  - makedirs: true
  - dir_mode: 755

kubefed_init:
  cmd.run:
  - name: kubefed init {{ master.federation.name }} --host-cluster-context=local --kubeconfig=/etc/kubernetes/federation/federation.kubeconfig --federation-system-namespace={{ master.federation.namespace }} --api-server-service-type={{ master.federation.service_type }} --api-server-advertise-address={{ master.apiserver.vip_address }} --etcd-persistent-storage=false  --dns-provider={{ master.federation.dns_provider }} --dns-provider-config=/etc/kubernetes/federation/dns.conf --dns-zone-name={{ master.federation.name }} --image={{ common.hyperkube.image }}
  - require:
    - file: /usr/bin/kubefed
    - file: /etc/kubernetes/federation/federation.kubeconfig
  - timeout: 120
  - unless: kubectl get namespace {{ master.federation.namespace }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

federation_kubeconfig_set_context:
  cmd.run:
  - name: kubectl config use-context {{ master.federation.name }}
  - env:
    - KUBECONFIG: /etc/kubernetes/federation/federation.kubeconfig
  - require:
    - cmd: kubefed_init
  - unless: kubectl config current-context | grep -w {{ master.federation.name }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

kubefed_join_host_cluster:
  cmd.run:
  - name: kubefed join {{ common.cluster_name }} --host-cluster-context=local --context={{ master.federation.name }}
  - env:
    - KUBECONFIG: /etc/kubernetes/federation/federation.kubeconfig
  - require:
    - cmd: kubefed_init
  - unless: kubectl --context={{ master.federation.name }} get cluster {{ common.cluster_name }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

# Assumes the following:
# * Pillar data master.federation.childclusters is populated
# * kubeconfig data for each cluster exists in /etc/kubernetes/federation/federation.kubeconfig
{%- if master.federation.get('childclusters') %}
{%- for childcluster in master.federation.childclusters %}

federation_set_insecure_{{ childcluster }}:
  cmd.run:
  - name: kubectl config set-cluster {{ childcluster }} --insecure-skip-tls-verify=true
  - env:
    - KUBECONFIG: /etc/kubernetes/federation/childclusters.kubeconfig
  - require:
    - cmd: kubefed_init
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- else %}
  - unless: kubectl --context {{ childcluster }} config view --minify | egrep "insecure-skip-tls-verify. true"
  {%- endif %}
   
federation_join_cluster_{{ childcluster }}:
  cmd.run:
  - name: kubefed join {{ childcluster }} --host-cluster-context=local --context={{ master.federation.name }}
  - env:
    - KUBECONFIG: /etc/kubernetes/federation/childclusters.kubeconfig:/etc/kubernetes/federation/federation.kubeconfig
  - require:
    - cmd: federation_set_insecure_{{ childcluster }}
  - unless: kubectl --context {{ master.federation.name }} get cluster {{ childcluster }}

{%- endfor %}
{%- endif %}

{%- endif %}
