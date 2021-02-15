
output "nomads" {
  value = {for key, value in data.ct_config.nomads : key => value.rendered}
}
