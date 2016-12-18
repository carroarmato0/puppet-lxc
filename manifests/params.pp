class lxc::params {
  $bindir                = '/usr/bin'
  $confdir               = '/etc/lxc'
  $globalconf            = '/etc/lxc/lxc.conf'
  $autostart_dir         = '/etc/lxc/auto'
  $templatedir           = '/usr/share/lxc/templates'
  $lxcinitdir            = '/usr/lib/x86_64-linux-gnu'
  $containerdir          = '/var/lib/lxc'

  case $::osfamily {
    'Debian': {
      $lxc_path              = 'lxc-config lxc.lxcpath'
      $lxc_vg                = 'lxc-config lxc.bdev.lvm.vg'
      $lxc_zfsroot           = 'lxc-config lxc.bdev.zfs.root'
      $extra_packages        = [
        'debootstrap',
        'cgroup-lite',
      ]
    }
    'Redhat': {
      $lxc_path              = 'lxc-config lxc.lxcpath'
      $lxc_vg                = 'lxc-config lxc.bdev.lvm.vg'
      $lxc_zfsroot           = 'lxc-config lxc.bdev.zfs.root'
      $extra_packages        = [
        'lxc-templates',
      ]
    }
    default: {
      $lxc_path              = 'lxc-config lxcpath'
      $lxc_vg                = 'lxc_config lvm_vg'
      $lxc_zfsroot           = 'lxc-config zfsroot'
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
