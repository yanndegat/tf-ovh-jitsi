terraform {
  required_version = "~> 0.12.8"

  required_providers {
    openstack = "~> 1.25"
    tls       = "~> 2.1"
    null      = "~> 2.1"
    template  = "~> 2.1"
  }
}
