# etcd assets
data "archive_file" "etcd_tls_zip" {
  type = "zip"

  output_path = "./.terraform/etcd_tls.zip"

  source {
    filename = "ca.crt"
    content  = "${var.etcd_ca_cert_pem}"
  }

  source {
    filename = "server.crt"
    content  = "${var.etcd_server_crt_pem}"
  }

  source {
    filename = "server.key"
    content  = "${var.etcd_server_key_pem}"
  }

  source {
    filename = "peer.crt"
    content  = "${var.etcd_peer_crt_pem}"
  }

  source {
    filename = "peer.key"
    content  = "${var.etcd_peer_key_pem}"
  }

  source {
    filename = "client.crt"
    content  = "${var.etcd_client_crt_pem}"
  }

  source {
    filename = "client.key"
    content  = "${var.etcd_client_key_pem}"
  }
}
