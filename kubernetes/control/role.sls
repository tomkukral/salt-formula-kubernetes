{% from "kubernetes/map.jinja" import control with context %}
include:
  - kubernetes.control

{%- for role_name, role in control.role.iteritems() %}
  {%- set role_name = role.name|default(role_name) %}

  {%- if role.get('namespace') or role.get('kind') == 'Role' %}
    {%- set role_kind = 'Role' %}
  {%- else %}
    {%- set role_kind = 'ClusterRole' %}
  {%- endif %}

  {%- if role.enabled|default(True) %}

    {%- if role.get('rules') %}
/srv/kubernetes/roles/{{ role_name }}/{{ role_name }}-role.yml:
  file.managed:
  - source: salt://kubernetes/files/role.yml
  - template: jinja
  - makedirs: true
  - require:
    - file: /srv/kubernetes
  - defaults:
      role_name: {{ role_name }}
      role_kind: {{ role_kind }}
      role: {{ role|yaml }}
    {%- endif %}

    {%- for binding_name, binding in role.get('binding', {}).iteritems() %}
      {%- set binding_name = binding.name|default(binding_name) %}
      {%- if binding.get('namespace') or binding.get('kind') == 'RoleBinding' %}
        {%- set binding_kind = 'RoleBinding' %}
      {%- else %}
        {%- set binding_kind = 'ClusterRoleBinding' %}
      {%- endif %}

/srv/kubernetes/roles/{{ role_name }}/{{ binding_name }}-rolebinding.yml:
  file.managed:
  - source: salt://kubernetes/files/rolebinding.yml
  - template: jinja
  - makedirs: true
  - require:
    - file: /srv/kubernetes
  - defaults:
      role_name: {{ role_name }}
      role_kind: {{ role_kind }}
      role: {{ role|yaml }}
      binding_name: {{ binding_name }}
      binding_kind: {{ binding_kind }}
      binding: {{ binding|yaml }}

    {%- endfor %}

  {%- endif %}
{%- endfor %}
