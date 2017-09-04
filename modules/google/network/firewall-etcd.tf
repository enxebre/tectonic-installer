resource "google_compute_firewall" "etcd-ingress" {
  name    = "ingress-etcd"
  network = "${google_compute_network.tectonic-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["2379", "2380", "12379"] # etcd and bootstrap-etcd
  }

  source_tags = ["tectonic-etcd"]
  target_tags = ["tectonic-etcd"]
}
