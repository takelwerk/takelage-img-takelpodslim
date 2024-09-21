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
    script = "${var.packer_template_dir}/bin/install-podman.bash"
  }

  post-processor "docker-tag" {
    repository = "${var.local_user}/${var.target_repo}"
    tags = ["${var.target_tag}"]
  }
}
