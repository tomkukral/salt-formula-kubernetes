{%- from "kubernetes/map.jinja" import master with context %}
{%- if master.enabled %}

/etc/kubernetes/kubeconfig.sh:
  file.managed:
    - source: salt://kubernetes/files/kubeconfig.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

generate_admin_kube_config:
  cmd.run:
    - name: /etc/kubernetes/kubeconfig.sh > /etc/kubernetes/admin-kube-config
    - watch:
      - file: /etc/kubernetes/kubeconfig.sh

{%- for addon_name, addon in master.addons.iteritems() %}
{%- if addon.enabled %}

kubernetes_addons_{{ addon_name }}:
  cmd.run:
    - name: "hyperkube kubectl apply -f /etc/kubernetes/addons/{{ addon_name }}"
    - unless: "hyperkube kubectl get {{ addon.get('creates', 'service') }} kube-{{ addon.get('name', addon_name) }} --namespace={{ addon.get('namespace', 'kube-system') }}"
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

{%- endif %}
{%- endfor %}

{%- if master.label is defined %}

{%- for name,label in master.label.iteritems() %}

{%- if label.enabled %}

{{ name }}_{{ label.node }}:
  k8s.label_present:
    - name: {{ label.key }}
    - value: {{ label.value }}
    - node: {{ label.node }}
    - apiserver: http://{{ master.apiserver.insecure_address }}:{{ master.apiserver.get('insecure_port', '8080') }}
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

{%- else %}

{{ name }}_{{ label.node }}:
  k8s.label_absent:
    - name: {{ label.key }}
    - node: {{ label.node }}
    - apiserver: http://{{ master.apiserver.insecure_address }}:{{ master.apiserver.get('insecure_port', '8080') }}
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

{%- endif %}

{%- endfor %}

{%- endif %}

{%- if master.addons.get('virtlet', {}).get('enabled') %}
{% for host in master.addons.virtlet.hosts %}

label_virtlet_{{ host }}:
  cmd.run:
    - name: kubectl label --overwrite node {{ host }} extraRuntime=virtlet
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

{% endfor %}

{%- endif %}

{%- endif %}
