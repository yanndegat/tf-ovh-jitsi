#
# Mandatory inputs
#

variable name {
  description = "The name prefix of the cluster"
}

variable email {
  description = "Email used for LetsEncrypt registration"
}

variable region_name {
  description = "Name of the region to be used by the openstack provider (refers to OS_REGION_NAME)"
}

variable cloud_name {
  description = "Name of the cloud to be used by the openstack provider (refers to OS_CLOUD). Defaults to var.name"
}

variable allowed_prefixes {
  description = "OVH offices, vpn, iplb ingress prefixes"
  type        = set(string)
  default     = []
}

#
# Optional inputs
#

variable ssh_keypair_name {
  type        = string
  description = "keypair to install on servers (has to be present in pki)"
  default     = "jitsi"
}

variable flavor_name {
  description = "Master node flavor name"
  default     = "b2-7"
}

variable image_name {
  description = "Name of an image to boot the nodes from (OS should be Ubuntu 16.04)"
  default     = "Ubuntu 18.04"
}

variable ssh_user {
  description = "Name of the user used in image_name"
  default     = "ubuntu"
}

variable fqdn {
  description = "Fully qualified domain name of the server. By default, will use the reverse name of the public ip"
  default     = ""
}

variable cronjob_enabled {
  description = "Enable cronjob to shelve/unshelve the jitsi server so it is not billed"
  default     = false
}

variable cronjob_unshelve {
  description = "Unshelve instance"
  default     = "00 16 * * *"
}

variable cronjob_shelve {
  description = "Shelve instance. (Put instance to sleep so it is not billed)"
  default     = "30 22 * * *"
}
