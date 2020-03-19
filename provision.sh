#!/bin/bash

set -eEuo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt update -y

sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common debconf-utils qemu-guest-agent

wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -
sudo sh -c "echo 'deb https://download.jitsi.org stable/' > /etc/apt/sources.list.d/jitsi-stable.list"
sudo apt-get -y update

#first install with a self signed cert. then restart with letsencrypt
cat > /tmp/jitsi.seeds <<EOF
jitsi-meet-web-config	jitsi-meet/cert-choice	select	Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate)
jitsi-meet-web-config	jitsi-meet/jvb-hostname	string	$(hostname)
jitsi-meet-web-config	jitsi-videobridge/jvb-hostname	string	$(hostname)
jitsi-videobridge	jitsi-videobridge/jvb-hostname	string	$(hostname)
EOF

sudo mkdir -p /etc/jitsi/videobridge/
sudo tee /etc/jitsi/videobridge/sip-communicator.properties <<EOF
org.jitsi.videobridge.rest.jetty.host=::
org.jitsi.videobridge.rest.jetty.port=443
org.jitsi.videobridge.rest.jetty.ProxyServlet.hostHeader=$(hostname)
org.jitsi.videobridge.rest.jetty.ProxyServlet.pathSpec=/http-bind
org.jitsi.videobridge.rest.jetty.ProxyServlet.proxyTo=http://localhost:5280/http-bind
org.jitsi.videobridge.rest.jetty.ResourceHandler.resourceBase=/usr/share/jitsi-meet
org.jitsi.videobridge.rest.jetty.ResourceHandler.alias./config.js=/etc/jitsi/meet/$(hostname)-config.js
org.jitsi.videobridge.rest.jetty.ResourceHandler.alias./interface_config.js=/usr/share/jitsi-meet/interface_config.js
org.jitsi.videobridge.rest.jetty.ResourceHandler.alias./logging_config.js=/usr/share/jitsi-meet/logging_config.js
org.jitsi.videobridge.rest.jetty.ResourceHandler.alias./external_api.js=/usr/share/jitsi-meet/libs/external_api.min.js
org.jitsi.videobridge.rest.jetty.RewriteHandler.regex=^/([a-zA-Z0-9]+)$
org.jitsi.videobridge.rest.jetty.RewriteHandler.replacement=/
org.jitsi.videobridge.rest.jetty.SSIResourceHandler.paths=/
org.jitsi.videobridge.rest.jetty.tls.port=443
org.jitsi.videobridge.TCP_HARVESTER_PORT=443
org.jitsi.videobridge.rest.jetty.sslContextFactory.keyStorePath=/etc/jitsi/videobridge/$(hostname).jks
org.jitsi.videobridge.rest.jetty.sslContextFactory.keyStorePassword=changeit
EOF

sudo debconf-set-selections /tmp/jitsi.seeds
sudo apt-get install -y jitsi-meet

# reinstall with proper letsencrypt certificate
sudo sh /tmp/install-letsencrypt-cert.sh
