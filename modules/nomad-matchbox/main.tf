locals {
  kernel = "${var.matchbox_http_endpoint}/assets/fedora-coreos/fedora-coreos-${var.os_version}-live-kernel-x86_64"
  initramfs = "${var.matchbox_http_endpoint}/assets/fedora-coreos/fedora-coreos-${var.os_version}-live-initramfs.x86_64.img"
  rootfs = "${var.matchbox_http_endpoint}/assets/fedora-coreos/fedora-coreos-${var.os_version}-live-rootfs.x86_64.img"

  boot_args = [
    "ip=dhcp",
    "rd.neednet=1",
    "console=tty0",
    "console=ttyS0",
    "coreos.live.rootfs_url=${local.rootfs}",
    "coreos.inst.install_dev=${var.install_disk}",
    #"coreos.inst.stream=${var.os_stream}",
    # for the next line to work, the .raw.xz must be downloaded to the appropriate place.
    # !!! AND the .raw.xz.sig file must be downloaded from the same location and placed next to the .raw.xz file !!!
    # If the .sig file is not present, there will be a hang-screen during PXE boot and no message why.
    "coreos.inst.image_url=${var.matchbox_http_endpoint}/assets/fedora-coreos/fedora-coreos-${var.os_version}-metal.x86_64.raw.xz",
    "coreos.inst.ignition_url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
  ]
}

resource "matchbox_profile" "nomads" {
  for_each = var.nomads
  name = each.value.name
  kernel = local.kernel
  initrd = [
    local.initramfs
  ]
  args = concat(local.boot_args, var.kernel_args)
  raw_ignition = each.value.ignition
}

resource "matchbox_group" "nomads" {
  for_each = var.nomads
  name = each.value.name
  profile = each.value.name
  selector = {
    mac = each.value.mac
  }
}