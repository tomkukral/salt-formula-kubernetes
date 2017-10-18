{% from "kubernetes/map.jinja" import control with context %}
include:
  - kubernetes.control.cluster
  {%- if control.job is defined %}
  - kubernetes.control.job
  {%- endif %}
  {%- if control.service is defined %}
  - kubernetes.control.service
  {%- endif %}
  {%- if control.configmap is defined %}
  - kubernetes.control.configmap
  {%- endif %}

/srv/kubernetes:
  file.directory:
  - makedirs: true
