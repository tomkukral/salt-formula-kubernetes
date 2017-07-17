{%- from "kubernetes/map.jinja" import master with context %}
{%- if master.enabled %}
{%- if master.network.get('version', 3.0) != 3.0 %}

opencontrail_kube_manager_package:
  pkg.installed:
  - name: contrail-kube-manager
  - force_yes: True

/etc/contrail/contrail-kubernetes.conf:
  file.managed:
  - source: salt://kubernetes/files/opencontrail/{{ master.network.version }}/contrail-kubernetes.conf
  - template: jinja
  - require:
    - pkg: opencontrail_kube_manager_package

{%- if master.network.get('systemd', true) %}

contrail_kube_manager:
  service.running:
    - name: contrail-kube-manager
    - enable: True
    - watch:
      - file: /etc/contrail/contrail-kubernetes.conf
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

{%- endif %}

{%- endif %}

{%- endif %}
