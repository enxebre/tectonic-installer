resource "google_compute_target_pool" "tectonic-master-targetpool" {
  name             = "tectonic-master-targetpool"
  session_affinity = "CLIENT_IP_PROTO"
}

resource "google_compute_target_pool" "tectonic-worker-targetpool" {
  name = "tectonic-worker-targetpool"
}

// Used by boostrap-ssh module
resource "google_compute_address" "tectonic-masters-ssh-ip" {
  name = "tectonic-masters-ssh-ip"
}

resource "google_compute_forwarding_rule" "tectonic-api-external-ssh-fwd-rule" {
  load_balancing_scheme = "EXTERNAL"
  name                  = "tectonic-api-external-ssh-fwd-rule"
  ip_address            = "${google_compute_address.tectonic-masters-ssh-ip.address}"
  region                = "${var.gcp_region}"
  target                = "${google_compute_target_pool.tectonic-master-targetpool.self_link}"
  port_range            = "22"
}

// Workers Ingress
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




//resource "google_compute_region_backend_service" "tectonic-master-backend" {
//  name        = "tectonic-master-backend"
//  protocol    = "TCP"
//  timeout_sec = 10
//  session_affinity = "NONE"
//  backend {
//    group = "${var.master_instance_group[0]}"
//  }
//
//  health_checks = ["${google_compute_health_check.tectonic-master-backend-health-check.self_link}"]
//}
//
//resource "google_compute_health_check" "tectonic-master-backend-health-check" {
//  name = "tectonic-master-backend-health-check"
////  unhealthy_threshold = 1
//  timeout_sec        = 1
//  check_interval_sec = 1
//
//  ssl_health_check {
//    port = "443"
//  }
//}
//
//resource "google_compute_forwarding_rule" "tectonic-api-internal-fwd-rule" {
//  load_balancing_scheme = "INTERNAL"
//  name                  = "tectonic-api-internal-fwd-rule"
//  ip_address            = "10.10.0.10"
//  region                = "${var.gcp_region}"
//  backend_service       = "${google_compute_region_backend_service.tectonic-master-backend.self_link}"
//  ports                 = ["443"]
//  network               = "${google_compute_network.tectonic-network.self_link}"
//  subnetwork            = "${google_compute_subnetwork.tectonic-master-subnet.self_link}"
//}

// api-server/masters lb
resource "google_compute_global_address" "tectonic-masters-ip" {
  name = "tectonic-masters-ip"
}

resource "google_compute_global_forwarding_rule" "tectonic-api-external-fwd-rule" {
  name       = "tectonic-api-external-fwd-rule"
  target     = "${google_compute_target_tcp_proxy.tectonic-api-external-tcp-proxy.self_link}"
  ip_address = "${google_compute_global_address.tectonic-masters-ip.address}"
  port_range = "443"
}

resource "google_compute_target_tcp_proxy" "tectonic-api-external-tcp-proxy" {
  name = "tectonic-api-external-tcp-proxy"
  description = "test"
  backend_service = "${google_compute_backend_service.tectonic-api-backend-service.self_link}"
}

resource "google_compute_backend_service" "tectonic-api-backend-service" {
  name        = "tectonic-api-backend-service"
  protocol    = "TCP"
  port_name   = "https"
  timeout_sec = 10
  session_affinity = "NONE"

  backend {
    group = "${var.master_instance_group[0]}"
  }

  health_checks = ["${google_compute_health_check.tectonic-api-health-check.self_link}"]
}

resource "google_compute_health_check" "tectonic-api-health-check" {
  name = "tectonic-api-health-check"
  timeout_sec        = 1
  check_interval_sec = 1

  ssl_health_check {
    port = "443"
  }
}
