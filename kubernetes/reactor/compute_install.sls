
orchestrate_kubernetes_compute_install:
  runner.state.orchestrate:
    - mods: kubernetes.orchestrate.compute_install
    - queue: True
    - pillar:
        event_originator: {{ data.id }}
        event_data: {{ data.data }}
