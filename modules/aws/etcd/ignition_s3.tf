locals {
  ignition_etcd_keys = ["ignition_etcd_0.json", "ignition_etcd_1.json", "ignition_etcd_2.json"]
}

data "ignition_config" "s3" {
  count = "${length(var.external_endpoints) == 0 ? var.instance_count : 0}"

  replace {
    source = "http://${var.cluster_name}-ncg.${var.base_domain}/ignition?profile=etcd"

    # TODO: add verification
  }
}
