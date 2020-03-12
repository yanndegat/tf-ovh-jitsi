#!/bin/bash

set -eEuo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt update -y

sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common debconf-utils

wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -
sudo sh -c "echo 'deb https://download.jitsi.org stable/' > /etc/apt/sources.list.d/jitsi-stable.list"
sudo apt-get -y update

#first install with a self signed cert. then restart with letsencrypt
cat > /tmp/jitsi.seeds <<EOF
jitsi-meet-web-config   jitsi-meet/cert-choice  select  Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate)
jitsi-meet-prosody      jitsi-meet-prosody/jvb-hostname string  $(hostname)
jitsi-meet-web-config   jitsi-meet/jvb-serve    boolean true
jitsi-meet-prosody      jicofo/jicofo-authuser  string  focus
jitsi-meet-web-config   jitsi-meet/cert-path-key        string
jicofo  jitsi-videobridge/jvb-hostname  string  $(hostname)
jitsi-meet-prosody      jitsi-videobridge/jvb-hostname  string  $(hostname)
jitsi-meet-web-config   jitsi-videobridge/jvb-hostname  string  $(hostname)
jitsi-videobridge       jitsi-videobridge/jvb-hostname  string  $(hostname)
jitsi-meet-web-config   jitsi-meet/cert-path-crt        string
jitsi-meet-web-config   jitsi-meet/jvb-hostname string  $(hostname)
EOF
sudo debconf-set-selections /tmp/jitsi.seeds
sudo apt-get install -y jitsi-meet

# reinstall with proper letsencrypt certificate
sudo sh /tmp/install-letsencrypt-cert.sh
