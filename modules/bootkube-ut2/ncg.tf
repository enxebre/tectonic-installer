resource "template_dir" "ncg_groups" {
  source_dir      = "${path.module}/resources/ncg/groups"
  destination_dir = "./generated/ncg-config/groups"

  vars {
    kube_dns_service_ip = "${cidrhost(var.service_cidr, 10)}"
  }
}

resource "template_dir" "ncg_profiles" {
  source_dir      = "${path.module}/resources/ncg/profiles"
  destination_dir = "./generated/ncg-config/profiles"
}

resource "template_dir" "ncg_clc" {
  source_dir      = "${path.module}/resources/ncg/clc"
  destination_dir = "./generated/ncg-config/clc"

  vars {
    ncg_config_etcd   = "${var.ncg_config_etcd}"
    ncg_config_master = "${var.ncg_config_master}"
    ncg_config_worker = "${var.ncg_config_worker}"
  }
}

resource "template_dir" "ncg_assets" {
  source_dir      = "${path.module}/resources/ncg/assets"
  destination_dir = "./generated/ncg-config/assets"
}
