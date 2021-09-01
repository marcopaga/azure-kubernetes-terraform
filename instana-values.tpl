cluster:
  name: "${cluster_name}"

agent:
  key: "${agent_key}"
  endpointHost: "saas-eu-west-1.instana.io"
  endpointPort: "443"

  pod:
    requests:
      memory: 512
      cpu: 0.5
    limits:
      memory: 768
      cpu: 1.5