{%- from "kubernetes/map.jinja" import master with context %}
{%- if master.enabled %}
{%- if master.network.get('version', 3.0) != 3.0 %}

/etc/contrail/contrail-kubernetes.conf:
  file.managed:
  - source: salt://kubernetes/files/opencontrail/{{ master.network.version }}/contrail-kubernetes.conf
  - template: jinja
  - makedirs: True

#/etc/kubernetes/opencontrail/contrail-{{ master.network.version }}.yaml:
#  file.managed:
#  - source: salt://kubernetes/files/manifest/contrail-{{ master.network.version }}.manifest
#  - template: jinja
#  - makedirs: True

{%- endif %}
{%- endif %}
