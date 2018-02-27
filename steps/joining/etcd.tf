module "etcd" {
  source = "../../modules/aws/etcd"

  base_domain             = "${var.tectonic_base_domain}"
  cluster_id              = "${local.cluster_id}"
  cluster_name            = "${var.tectonic_cluster_name}"
  container_image         = "${var.tectonic_container_images["etcd"]}"
  container_linux_channel = "${var.tectonic_container_linux_channel}"
  container_linux_version = "${local.container_linux_version}"
  ec2_type                = "${var.tectonic_aws_etcd_ec2_type}"
  external_endpoints      = "${compact(var.tectonic_etcd_servers)}"
  extra_tags              = "${var.tectonic_aws_extra_tags}"
  instance_count          = "${local.etcd_count}"
  root_volume_iops        = "${var.tectonic_aws_etcd_root_volume_iops}"
  root_volume_size        = "${var.tectonic_aws_etcd_root_volume_size}"
  root_volume_type        = "${var.tectonic_aws_etcd_root_volume_type}"

  //  s3_bucket               = "${aws_s3_bucket.tectonic.bucket}"
  sg_ids        = "${concat(var.tectonic_aws_etcd_extra_sg_ids, local.etcd_sg)}"
  ssh_key       = "${var.tectonic_aws_ssh_key}"
  subnets       = "${local.subnet_ids_workers}"
  etcd_iam_role = "${var.tectonic_aws_etcd_iam_role_name}"
  ec2_ami       = "${var.tectonic_aws_ec2_ami_override}"
}

resource "aws_route53_record" "etcd_a_nodes" {
  depends_on = ["aws_route53_record.ngc_internal"]
  count      = "${local.etcd_count}"
  type       = "A"
  ttl        = "60"
  zone_id    = "${local.private_zone_id}"
  name       = "${var.tectonic_cluster_name}-etcd-${count.index}"
  records    = ["${module.etcd.ip_addresses[count.index]}"]
}
