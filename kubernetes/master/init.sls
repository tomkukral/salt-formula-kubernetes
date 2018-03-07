{%- from "kubernetes/map.jinja" import master with context %}
include:
- kubernetes.master.service
- kubernetes.master.kube-addons
{%- if "flannel" in master.network.cnis %}
- kubernetes.master.flannel
{%- endif %}
{%- if "opencontrail" in master.network.cnis %}
- kubernetes.master.opencontrail
{%- endif %}
{%- if "calico" in master.network.cnis %}
{%- if not pillar.kubernetes.pool is defined %}
- kubernetes.master.calico
{%- endif %}
{%- endif %}
{%- if "genie" in master.network.cnis %}
{%- if not pillar.kubernetes.pool is defined %}
- kubernetes.master.genie
{%- endif %}
{%- endif %}
{%- if master.storage.get('engine', 'none') == 'glusterfs' %}
- kubernetes.master.glusterfs
{%- endif %}
- kubernetes.master.controller
- kubernetes.master.setup
