{%- from "kubernetes/map.jinja" import pool with context %}
{%- if pool.enabled %}

/etc/cni/net.d/11-opencontrail.conf:
  file.managed:
    - source: salt://kubernetes/files/opencontrail/opencontrail.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - dir_mode: 755
    - template: jinja


{%- endif %}
