#!/bin/bash

apt-get update
apt-get --yes dist-upgrade
apt-get --yes --no-install-recommends install \
  aardvark-dns \
  ca-certificates \
  iptables \
  libvshadow-utils \
  passt \
  podman \
  podman-compose \
  python3-minimal \
  python3-apt \
  uidmap
apt-get clean
mkdir -p  /var/run/containers/storage
mkdir -p /var/lib/containers
cat > /etc/containers/storage.conf <<storage_conf
[storage]
driver = "vfs"
runroot = "/var/run/containers/storage"
graphroot = "/var/lib/containers"
storage_conf
/usr/sbin/useradd \
  --comment 'podman user to run rootless containers' \
  --home-dir /home/podman \
  --create-home \
  --shell /bin/bash \
  --user-group \
  podman
su podman -c 'mkdir -p /home/podman/.config/containers'
su podman -c 'echo -e "[storage]\ndriver = \"vfs\"\n" > /home/podman/.config/containers/storage.conf'
