output "ignition_bootstrap" {
  value = "${data.ignition_config.bootstrap.rendered}"
}
