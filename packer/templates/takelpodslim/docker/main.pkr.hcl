packer {
  required_plugins {
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
  }
}

source "docker" "takelpodslim" {
  # export_path = "images/docker/${var.target_repo}.tar"
  image = "${var.base_repo}:${var.base_tag}"
  commit = true
  pull = false
  run_command = [
    "--detach",
    "--interactive",
    "--tty",
    "--name",
    "${var.target_repo}",
    "${var.base_user}:${var.base_tag}",
    "/bin/bash"
  ]
  changes = [
    "WORKDIR /root",
    "ENV DEBIAN_FRONTEND=noninteractive",
    "ENV LANG=C.UTF-8",
    "ENV SUPATH=$PATH",
    "ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    "CMD [\"/bin/bash\"]"
  ]
}

build {
  sources = [
    "source.docker.takelpodslim"
  ]

  provisioner "shell" {
    inline = [
      "apt update",
      "apt --yes full-upgrade",
      "apt --yes --no-install-recommends install ca-certificates libvshadow-utils podman podman-compose python3-minimal python3-apt slirp4netns uidmap",
      "/usr/sbin/useradd --comment 'podman user to run rootless containers' --home-dir /home/podman --create-home --shell /bin/bash --user-group podman",
    ]
  }

  post-processor "docker-tag" {
    repository = "${var.local_user}/${var.target_repo}"
    tags = ["${var.target_tag}"]
  }
}
