{%- from "kubernetes/map.jinja" import master with context %}
{%- if master.enabled %}

/etc/kubernetes/manifests/kube-network-manager.manifest:
  file.managed:
    - source: salt://kubernetes/files/opencontrail/kube-network-manager.manifest
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - dir_mode: 755
    - template: jinja

/etc/kubernetes/network.conf:
  file.managed:
    - source: salt://kubernetes/files/opencontrail/network.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - dir_mode: 755
    - template: jinja

{%- endif %}