{%- from "kubernetes/map.jinja" import pool with context %}
include:
- kubernetes.pool.cni
{%- if "calico" in pool.network.cnis %}
- kubernetes.pool.calico
{%- endif %}
{%- if "opencontrail" in pool.network.cnis %}
- kubernetes.pool.opencontrail
{%- endif %}
- kubernetes.pool.service
{%- if "flannel" in pool.network.cnis %}
- kubernetes.pool.flannel
{%- endif %}
{%- if "genie" in pool.network.cnis %}
- kubernetes.pool.genie
{%- endif %}
- kubernetes.pool.kube-proxy
