output host {
  description = "host ipv4"
  value       = local.jitsi
}

output ssh_private_key {
  description = "ssh private key to use to connect to the host"
  sensitive   = true
  value       = tls_private_key.priv.private_key_pem
}

output ssh_helper {
  value = "eval $(ssh-agent); terraform output ssh_private_key | ssh-add -; ssh ubuntu@${local.jitsi}"
}


output friendly_helper {
  value = <<EOF

Your Jitsi instance shall be up and accessible at the following address:

     https://${local.fqdn}

EOF
}

