
locals {
  nomad_servers = {for k, v in var.nomads : k => v if contains(v.roles, "server")}
  nomad_clients = {for k, v in var.nomads : k => v if contains(v.roles, "client")}
}

//resource "local_file" "nomadd" {
//  for_each = var.nomads
//  filename = "outputs/nomad${each.key}.yaml"
//  content = templatefile("${path.module}/templates/nomad.yaml", {
//    nomad_version = var.nomad_version,
//    nomad_driver_podman_version = var.nomad_driver_podman_version
//    roles = each.value.roles
//    public_ip = each.value.public_ip
//    cluster_ip = each.value.cluster_ip
//    bootstrap_expect = length(local.nomad_servers)
//    nomad_servers = join(",", [for v in values(local.nomad_servers) : format("\"%s:4647\"", v.cluster_ip)])
//  })
//}

data "ct_config" "nomads" {
  for_each = var.nomads
  strict = true
  pretty_print = false
  content = templatefile("${path.module}/templates/nomad.yaml", {
    nomad_version = var.nomad_version,
    driver_podman_version = var.nomad_driver_podman_version
    hostname = each.value.hostname
    roles = each.value.roles
    public_ip = each.value.public_ip
    cluster_ip = each.value.cluster_ip
    bootstrap_expect = length(local.nomad_servers)
    nomad_servers = join(",", [for v in values(local.nomad_servers) : format("\"%s\"", v.cluster_ip)])
  })

  snippets = each.value.snippets
}


