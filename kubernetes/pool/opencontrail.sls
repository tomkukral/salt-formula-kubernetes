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

/opt/cni/bin/opencontrail:
  file.managed:
    - source: http://apt.tcpcloud.eu/kubernetes/bin/opencontrail
    - user: root
    - group: root
    - mode: 755
    - makedirs: true
    - dir_mode: 755
    - template: jinja
    - source_hash: md5={{ pool.network.hash }}
{%- endif %}
