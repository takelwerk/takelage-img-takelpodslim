#!/bin/bash

apt-get update
apt-get --yes dist-upgrade
apt-get --yes --no-install-recommends install \
  aardvark-dns \
  ca-certificates \
  libvshadow-utils \
  passt \
  podman \
  podman-compose \
  python3-minimal \
  python3-apt \
  slirp4netns \
  uidmap
apt-get clean
/usr/sbin/useradd \
  --comment 'podman user to run rootless containers' \
  --home-dir /home/podman \
  --create-home \
  --shell /bin/bash \
  --user-group \
  podman
su podman -c 'mkdir -p /home/podman/.config/containers'
su podman -c 'echo -e "[storage]\ndriver = \"vfs\"\n" > /home/podman/.config/containers/storage.conf'
/usr/sbin/useradd \
  --comment 'podman mac user to run rootless containers' \
  --gid 20 \
  --home-dir /home/podmac \
  --create-home \
  --shell /bin/bash \
  --uid 501 \
  podmac
usermod --add-subuids 200000-265535 --add-subgids 200000-265535 podmac
su podmac -c 'mkdir -p /home/podmac/.config/containers'
su podmac -c 'echo -e "[storage]\ndriver = \"vfs\"\n" > /home/podmac/.config/containers/storage.conf'
