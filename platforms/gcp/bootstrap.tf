locals {
  "bootstrapping_host" = "${module.dns.kube_apiserver_fqdn}"
}

module "bootstrapper" {
  source = "../../modules/bootstrap-ssh"

  _dependencies = [
    "${module.etcd.etcd_ip_addresses}",
    "${module.etcd_certs.id}",
    "${module.bootkube.id}",
    "${module.tectonic.id}",
    "${module.flannel-vxlan.id}",
    "${module.calico-network-policy.id}",
  ]

  bootstrapping_host = "${local.bootstrapping_host}"
}
