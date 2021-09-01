variable "agent_count" {
  default = 3
}

variable "dns_prefix" {
  default = "terraform-test"
}

variable cluster_name {
  default = "terraform-test"
}

variable resource_group_name {
  default = "rg-terraform-test"
}

variable acme_staging {
  default     = "true"
  description = "Change to false if you need a production ACME certificate. Check the rate limits before applying."
}

variable location {
  default = "West Europe"
}
variable instana_agent_key {
  description = "Get it from https://tenant.instana.io/ump/tenant/tenant/agentkeys/ "
}