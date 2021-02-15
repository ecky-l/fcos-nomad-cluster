
variable "nomad_version" {
  type = string
  default = "1.0.3"
}

variable "nomads" {
  type = map(object({
    roles = list(string)
    public_ip = string
    cluster_ip = string
    snippets = list(string)
  }))
}

variable "snippets" {
  type = map(list(string))
  description = "additional ignition snippets"
  default = {}
}
