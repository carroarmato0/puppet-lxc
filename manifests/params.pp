class lxc::params {
  $bindir                = '/usr/bin'
  $confdir               = '/etc/lxc'
  $globalconf            = '/etc/lxc/lxc.conf'
  $autostart_dir         = '/etc/lxc/auto'
  $templatedir           = '/usr/share/lxc/templates'
  $lxcinitdir            = '/usr/lib/x86_64-linux-gnu'
  $containerdir          = '/var/lib/lxc'
  $autostart             = 1

  # If the detected vesion of LXC is 1.x.x
  if versioncmp($::lxc_version, '2.0.0') == -1 {
    $lxc_path              = 'lxc-config lxc.lxcpath'
    $lxc_vg                = 'lxc-config lxc.bdev.lvm.vg'
    $lxc_zfsroot           = 'lxc-config lxc.bdev.zfs.root'
    $lxc_list              = 'lxc-ls'
  } else {
    # If version is 2.x.x
    $lxc_path              = 'lxc config lxc.lxcpath'
    $lxc_vg                = 'lxc config lxc.bdev.lvm.vg'
    $lxc_zfsroot           = 'lxc config lxc.bdev.zfs.root'
    $lxc_list              = 'lxc list'
  }

  case $::osfamily {
    'Debian': {
      $extra_packages        = [
        'debootstrap',
        'cgroup-lite',
      ]
    }
    'Redhat': {
      $extra_packages        = [
        'lxc-templates',
        'lxc-extra',
      ]
    }
    default: {
      $extra_packages        = []
    }
  }

  $network_type          = 'veth'
  $network_link          = 'lxcbr0'
  $network_flags         = 'up'
  $fstype                = 'ext4'
  $fssize                = '1G'
  $vgname                = 'lxc'
  $supported_templates   = [
                            'alpine',
                            'altlinux',
                            'archlinux',
                            'busybox',
                            'cirros',
                            'debian',
                            'fedora',
                            'opensuse',
                            'oracle',
                            'sshd',
                            'ubuntu',
                            'ubuntu-cloud',
                           ]
  $allowed_backingstores = [
                            'none',
                            'dir',
                            'lvm',
                            'loop',
                            'btrfs'
                           ]
}
