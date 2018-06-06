locals {
  ignition_etcd_keys = ["ignition_etcd_0.json", "ignition_etcd_1.json", "ignition_etcd_2.json"]
}

data "ignition_config" "tnc" {
  count = "${length(var.external_endpoints) == 0 ? var.instance_count : 0}"

  append {
    source = "${format("http://${var.cluster_name}-tnc.${var.base_domain}/config/etcd?etcd_index=%d", count.index)}"

    # TODO: add verification
  }
}
