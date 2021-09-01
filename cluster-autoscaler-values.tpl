rbac:
  create: true
cloudProvider: azure
azureClusterName: "${cluster_name}"
azureClientID: "${sp_client_id}"
azureClientSecret: "${sp_client_secret}"
azureSubscriptionID: "${subscription_id}"
azureTenantID: "${tenant_id}"
azureResourceGroup: "${resource_group}"
azureNodeResourceGroup: "${node_resource_group}"
azureVmType: AKS
autoscalingGroups:
  - name: default
    minSize: 4
    maxSize: 20
priorityClassName: system-cluster-critical
extraArgs:
  skip-nodes-with-local-storage: "false"
  skip-nodes-with-system-pods: "false"
  expendable-pods-priority-cutoff: -10
  expander: least-waste
resources:
  requests:
    memory: "256Mi"
    cpu: "0.2"
  limits:
    memory: "256Mi"
    cpu: "0.2"
tolerations:
  - effect: "NoSchedule"
    operator: "Exists"
    key: "node.kubernetes.io/unschedulable"
