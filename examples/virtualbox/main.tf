locals {
  enp0s3_ipv4 = {
    "method" = "manual"
    "address1" = "10.10.0.10/16,10.10.0.1"
    "dns" = "10.10.0.1;"
    "dns-search" = "local.vlan;"
    "never-default" = "true"
  }
  enp0s8_ipv4 = {
    "method" = "manual"
    "address1" = "192.168.56.20/24"
    "never-default" = "true"
  }
  enp0s9_ipv4 = {
    "ipv4" = {
      "method" = "auto"
    }
  }
}

module "vb_snippets" {
  source = "git::https://github.com/ecky-l/fcos-ignition-snippets.git//modules/ignition-snippets"
  user_authorized_keys = {
    n1 = [
      file("~/.ssh/id_rsa.pub")
    ]
    n2 = [
      file("~/.ssh/id_rsa.pub")
    ]
  }
  networks = {
    n1 = {
      enp0s3 = {
        ipv4 = merge(local.enp0s3_ipv4, {address1="10.10.0.20/16,10.10.0.1"})
      }
      enp0s8 = {
        ipv4 = merge(local.enp0s8_ipv4, {address1="192.168.56.40/24"})
      }
      enp0s9 = local.enp0s9_ipv4
    }
    n2 = {
      enp0s3 = {
        ipv4 = merge(local.enp0s3_ipv4, {address1="10.10.0.21/16,10.10.0.1"})
      }
      enp0s8 = {
        ipv4 = merge(local.enp0s8_ipv4, {address1="192.168.56.41/24"})
      }
      enp0s9 = local.enp0s9_ipv4
    }
  }
  root_partition = {
    n1 = {}
    n2 = {}
  }
}

module "vb_nomad" {
  source = "../../modules/nomad-ignition"

  nomads = {
    "n1" = {
      roles = ["server", "client"]
      hostname = "n1.local.vlan"
      public_ip = "192.168.56.40"
      cluster_ip = "10.10.0.20"
      snippets = [
        module.vb_snippets.user_snippets.n1.content,
        module.vb_snippets.network_snippets.n1.content,
        module.vb_snippets.storage_snippets.n1.content,
      ]
    }
    "n2" = {
      roles = ["server", "client"]
      hostname = "n2.local.vlan"
      public_ip = "192.168.56.41"
      cluster_ip = "10.10.0.21"
      snippets = [
        module.vb_snippets.user_snippets.n2.content,
        module.vb_snippets.network_snippets.n2.content,
        module.vb_snippets.storage_snippets.n2.content,
      ]
    }
  }
}

resource "local_file" "nomad_ignitions" {
  for_each = module.vb_nomad.nomads
  content = each.value
  filename = "outputs/${each.key}.ign"
}

module "vb_nomad_matchbox" {
  source = "../../modules/nomad-matchbox"
  matchbox_http_endpoint = "http://10.10.0.1:8080"

  nomads = {
    n1 = {
      name = "n1"
      domain = "n1.local.vlan"
      mac = "08:00:27:DD:29:42"
      ignition = module.vb_nomad.nomads["n1"]
    }
    n2 = {
      name = "n2"
      domain = "n2.local.vlan"
      mac = "08:00:27:CD:8D:37"
      ignition = module.vb_nomad.nomads["n2"]
    }
  }
}