
orchestrate_kubernetes_compute_upgrade:
  runner.state.orchestrate:
    - mods: kubernetes.orchestrate.compute_upgrade
    - queue: True
    - pillar:
        event_originator: {{ data.id }}
        event_data: {{ data.data }}
