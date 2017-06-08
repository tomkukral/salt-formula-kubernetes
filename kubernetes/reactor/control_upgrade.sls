
orchestrate_kubernetes_control_upgrade:
  runner.state.orchestrate:
    - mods: kubernetes.orchestrate.control_upgrade
    - queue: True
    - pillar:
        event_originator: {{ data.id }}
        event_data: {{ data.data }}
