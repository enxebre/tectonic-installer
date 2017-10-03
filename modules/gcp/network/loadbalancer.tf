resource "google_compute_target_pool" "tectonic-master-targetpool" {
  name             = "tectonic-master-targetpool"
  session_affinity = "NONE"
}

resource "google_compute_target_pool" "tectonic-worker-targetpool" {
  name = "tectonic-worker-targetpool"
}

resource "google_compute_address" "tectonic-masters-ip" {
  name = "tectonic-masters-ip"
}

resource "google_compute_forwarding_rule" "tectonic-api-external-fwd-rule" {
  load_balancing_scheme = "EXTERNAL"
  name                  = "tectonic-api-external-fwd-rule"
  ip_address            = "${google_compute_address.tectonic-masters-ip.address}"
  region                = "${var.gcp_region}"
  target                = "${google_compute_target_pool.tectonic-master-targetpool.self_link}"
  port_range            = "443"
}

resource "google_compute_forwarding_rule" "tectonic-api-external-ssh-fwd-rule" {
  load_balancing_scheme = "EXTERNAL"
  name                  = "tectonic-api-external-ssh-fwd-rule"
  ip_address            = "${google_compute_address.tectonic-masters-ip.address}"
  region                = "${var.gcp_region}"
  target                = "${google_compute_target_pool.tectonic-master-targetpool.self_link}"
  port_range            = "22"
}

resource "google_compute_address" "tectonic-ingress-ip" {
  name = "tectonic-ingress-ip"
}

resource "google_compute_forwarding_rule" "tectonic-ingress-external-http-fwd-rule" {
  load_balancing_scheme = "EXTERNAL"
  name                  = "tectonic-ingress-external-http-fwd-rule"
  ip_address            = "${google_compute_address.tectonic-ingress-ip.address}"
  region                = "${var.gcp_region}"
  target                = "${google_compute_target_pool.tectonic-worker-targetpool.self_link}"
  port_range            = "80"
}

resource "google_compute_forwarding_rule" "tectonic-ingress-external-https-fwd-rule" {
  load_balancing_scheme = "EXTERNAL"
  name                  = "tectonic-ingress-external-https-fwd-rule"
  ip_address            = "${google_compute_address.tectonic-ingress-ip.address}"
  region                = "${var.gcp_region}"
  target                = "${google_compute_target_pool.tectonic-worker-targetpool.self_link}"
  port_range            = "443"
}

resource "google_compute_region_backend_service" "tectonic-master-backend" {
  name        = "tectonic-master-backend"
  protocol    = "TCP"
  timeout_sec = 10
  session_affinity = "NONE"
  backend {
    group = "${var.master_instance_group[0]}"
  }

  health_checks = ["${google_compute_health_check.tectonic-master-backend-health-check.self_link}"]
}

resource "google_compute_health_check" "tectonic-master-backend-health-check" {
  name = "tectonic-master-backend-health-check"
//  unhealthy_threshold = 1
  timeout_sec        = 1
  check_interval_sec = 1

  ssl_health_check {
    port = "443"
  }
}

resource "google_compute_forwarding_rule" "tectonic-api-internal-fwd-rule" {
  load_balancing_scheme = "INTERNAL"
  name                  = "tectonic-api-internal-fwd-rule"
  ip_address            = "10.10.0.10"
  region                = "${var.gcp_region}"
  backend_service       = "${google_compute_region_backend_service.tectonic-master-backend.self_link}"
  ports                 = ["443"]
  network               = "${google_compute_network.tectonic-network.self_link}"
  subnetwork            = "${google_compute_subnetwork.tectonic-master-subnet.self_link}"
}
