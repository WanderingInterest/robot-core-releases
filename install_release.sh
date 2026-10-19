#!/bin/sh
set -eu
# Run on the destination computer, alongside the independently obtained public key.
[ "$(id -u)" = 0 ] || { echo "Run as root on the destination PC"; exit 1; }
url=${1:?Supply your GitHub Pages HTTPS repository URL}
case "$url" in https://*.github.io/*) ;; *) echo "Expected a GitHub Pages HTTPS URL"; exit 1;; esac
case "$url" in *[!a-zA-Z0-9:/._-]*) echo "Invalid URL"; exit 1;; esac
key=$(dirname "$0")/robot-core-archive-keyring.asc
[ -f "$key" ] || { echo "Missing independently supplied release key"; exit 1; }
install -m 644 "$key" /usr/share/keyrings/robot-core-archive-keyring.asc
printf 'Types: deb\nURIs: %s\nSuites: stable\nComponents: main\nArchitectures: amd64\nSigned-By: /usr/share/keyrings/robot-core-archive-keyring.asc\n' "$url" > /etc/apt/sources.list.d/robot-core.sources
apt-get update
apt-get install -y robot-core-desktop
systemctl daemon-reload
systemctl enable --now robot-core-update.timer
echo 'Installed. Updates activate after restarting Robot Core; user data stays in your home directory.'
