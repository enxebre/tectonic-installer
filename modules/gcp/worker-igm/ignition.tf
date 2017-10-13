data "ignition_config" "main" {
  files = [
    "${var.ign_max_user_watches_id}",
    "${var.ign_gcs_puller_id}",
    "${var.ign_installer_kubelet_env_id}",
    "${data.ignition_file.cloud_config_w.id}",
  ]

  systemd = [
    "${var.ign_docker_dropin_id}",
    "${var.ign_k8s_node_bootstrap_service_id}",
    "${var.ign_locksmithd_service_id}",
    "${var.ign_kubelet_service_id}",
  ]
}

data "ignition_file" "cloud_config_w" {
  filesystem = "root"
  path       = "/etc/kubernetes/cloud/config"
  mode       = 0755

  content {
    content = "${data.template_file.cloud_config_w.rendered}"
  }
}

data "template_file" "cloud_config_w" {
  template = "${file("${path.module}/resources/config")}"

  vars {

  }
}
