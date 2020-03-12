terraform {
  backend "swift" {}
}

provider openstack {
  cloud  = var.cloud_name
  region = var.region_name
}

resource tls_private_key priv {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource openstack_compute_keypair_v2 keypair {
  name       = var.ssh_keypair_name
  public_key = tls_private_key.priv.public_key_openssh
}

#
# Network objects
#
data openstack_networking_network_v2 ext_net {
  name      = "Ext-Net"
  tenant_id = ""
}

data openstack_images_image_v2 image {
  name        = var.image_name
  most_recent = true
}

resource openstack_networking_secgroup_v2 secgroup {
  name        = var.name
  description = "Security gropup for Jitsi"
}

resource openstack_networking_secgroup_rule_v2 ingress_https_jitsi {
  for_each = var.allowed_prefixes

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = each.key
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource openstack_networking_secgroup_rule_v2 ingress_http_01_challenge {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80 # required for http letsencrypt challenge
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource openstack_networking_secgroup_rule_v2 ingress_tcp_ssh {
  for_each = var.allowed_prefixes

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = each.key
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource openstack_networking_port_v2 fip {
  name           = var.name
  network_id     = data.openstack_networking_network_v2.ext_net.id
  admin_state_up = "true"

  security_group_ids = [openstack_networking_secgroup_v2.secgroup.id]
}


locals {
  jitsi = [
    for ip in openstack_networking_port_v2.fip.all_fixed_ips :
    ip
    if length(replace(ip, "/[[:alnum:]]+:[^,]+/", "")) > 0
  ][0]

  ip_parts = split(".", local.jitsi)
  fqdn     = format("ip%s.ip-%s-%s-%s.eu", local.ip_parts[3], local.ip_parts[0], local.ip_parts[1], local.ip_parts[2])

  user_data = {
    hostname = local.fqdn
    fqdn     = local.fqdn
  }

}

resource openstack_compute_instance_v2 vm {
  name        = var.name
  image_id    = data.openstack_images_image_v2.image.id
  flavor_name = var.flavor_name
  key_pair    = openstack_compute_keypair_v2.keypair.name

  user_data = <<EOF
#cloud-config
${yamlencode(local.user_data)}
EOF
  network {
    port           = openstack_networking_port_v2.fip.id
    access_network = true
  }
}

data template_file install_letsencrypt_cert {
  template = file("${path.module}/install-letsencrypt-cert.sh")
  vars = {
    DOMAIN = local.fqdn
    EMAIL  = var.email
  }
}

resource null_resource provision {
  triggers = {
    jitsi     = openstack_compute_instance_v2.vm.id
    provision = md5(file("${path.module}/provision.sh"))
  }

  provisioner "file" {
    connection {
      user        = "ubuntu"
      host        = local.jitsi
      private_key = tls_private_key.priv.private_key_pem
    }

    content = data.template_file.install_letsencrypt_cert.rendered
    destination = "/tmp/install-letsencrypt-cert.sh"
  }

  provisioner "remote-exec" {
    connection {
      user        = "ubuntu"
      host        = local.jitsi
      private_key = tls_private_key.priv.private_key_pem
    }

    script = "${path.module}/provision.sh"
  }
}
