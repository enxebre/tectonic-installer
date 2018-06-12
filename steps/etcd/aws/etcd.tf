provider "aws" {
  region  = "${var.tectonic_aws_region}"
  profile = "${var.tectonic_aws_profile}"
  version = "1.8.0"

  assume_role {
    role_arn     = "${var.tectonic_aws_installer_role == "" ? "" : "${var.tectonic_aws_installer_role}"}"
    session_name = "TECTONIC_INSTALLER_${var.tectonic_cluster_name}"
  }
}

module "container_linux" {
  source = "../../../modules/container_linux"

  release_channel = "${var.tectonic_container_linux_channel}"
  release_version = "${var.tectonic_container_linux_version}"
}

data "aws_availability_zones" "azs" {}

data "template_file" "etcd_hostname_list" {
  count    = "${var.tectonic_etcd_count > 0 ? var.tectonic_etcd_count : length(data.aws_availability_zones.azs.names) == 5 ? 5 : 3}"
  template = "${var.tectonic_cluster_name}-etcd-${count.index}.${var.tectonic_base_domain}"
}

module "etcd" {
  source = "../../../modules/aws/etcd"

  base_domain             = "${var.tectonic_base_domain}"
  cluster_id              = "${var.tectonic_cluster_id}"
  cluster_name            = "${var.tectonic_cluster_name}"
  container_image         = "${var.tectonic_container_images["etcd"]}"
  container_linux_channel = "${var.tectonic_container_linux_channel}"
  container_linux_version = "${module.container_linux.version}"
  ec2_type                = "${var.tectonic_aws_etcd_ec2_type}"
  external_endpoints      = "${compact(var.tectonic_etcd_servers)}"
  extra_tags              = "${var.tectonic_aws_extra_tags}"
  instance_count          = "${length(data.template_file.etcd_hostname_list.*.id)}"
  root_volume_iops        = "${var.tectonic_aws_etcd_root_volume_iops}"
  root_volume_size        = "${var.tectonic_aws_etcd_root_volume_size}"
  root_volume_type        = "${var.tectonic_aws_etcd_root_volume_type}"
  s3_bucket               = "${local.s3_bucket}"
  sg_ids                  = "${concat(var.tectonic_aws_etcd_extra_sg_ids, list(local.sg_id))}"
  ssh_key                 = "${var.tectonic_aws_ssh_key}"
  subnets                 = ["${local.subnet_ids_workers}"]
  etcd_iam_role           = "${var.tectonic_aws_etcd_iam_role_name}"
  ec2_ami                 = "${var.tectonic_aws_ec2_ami_override}"
}

resource "aws_route53_record" "etcd_a_nodes" {
  count   = "${length(data.template_file.etcd_hostname_list.*.id)}"
  type    = "A"
  ttl     = "60"
  zone_id = "${local.private_zone_id}"
  name    = "${var.tectonic_cluster_name}-etcd-${count.index}"
  records = ["${module.etcd.ip_addresses[count.index]}"]
}
