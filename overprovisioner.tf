resource "helm_release" "overprovisioner" {
  chart     = "stable/cluster-overprovisioner"
  name      = "overprovisioner"
  version   = "0.2.3"
  namespace = "overprovisioner"
  values    = [file("overprovioner-values.yaml")]
  timeout   = "600"
}