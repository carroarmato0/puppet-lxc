define lxc::container (
  $template,
  $ensure       = present,
  $vgname       = $lxc::params::vgname,
  $fstype       = $lxc::params::fstype,
  $fssize       = $lxc::params::fssize,
  $backingstore = 'none',
  $autostart    = true,
){

  include lxc

  #validate_re($template, $lxc::params::supported_templates,'Template not supported')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/var/lib/lxc/${name}":
    ensure => directory,
  }

  file { "/var/lib/lxc/${name}/config":
    ensure => file,
  }

  if $autostart {
    file { "/etc/lxc/auto/${name}.conf":
      ensure  => link,
      target  => "/var/lib/lxc/${name}/config",
      require => [File['/etc/lxc/auto'],File["/var/lib/lxc/${name}"],File["/var/lib/lxc/${name}/config"]],
    }
  }

  case $ensure {
    'present', 'install': {

      case $backingstore {
        'lvm': {
          exec { "Create a ${template} container ${name} with LVM backend, ${vgname} volume group, ${fstype} FS and ${fssize} big":
            command => "lxc-create -n ${name} -t ${template} -B lvm --vgname=${vgname} --fstype=${fstype} --fssize=${fssize}",
            unless  => "lxc-ls ${name}",
          }
        }
        'loop': {
          exec { "Create a ${template} container ${name} with loop":
            command => "lxc-create -n ${name} -t ${template} -B loop",
            unless  => "lxc-ls ${name}",
          }
        }
        'btrfs': {
          exec { "Create a ${template} container ${name} with btrfs":
            command => "lxc-create -n ${name} -t ${template} -B btrfs",
            unless  => "lxc-ls ${name}",
          }
        }
        'none', default: {
          exec { "Create a ${template} container ${name} with minimal defaults":
            command => "lxc-create -n ${name} -t ${template}",
            unless  => "lxc-ls ${name}",
          }
        }
      }

      exec { "Start container ${name}":
        command => "lxc-start -d -n ${name}",
        unless  => "lxc-ls --active ${name}",
      }
    }
    'stopped', 'shutdown', 'halted': {
      exec { "Stop container ${name}":
        command => "lxc-stop -n ${name}",
        unless => "lxc-ls --stopped ${name}",
      }
    }
    'purge','delete','destroy','absent': {
      exec { "Purge container ${name}":
        command => "lxc-destroy -n ${name}",
        require => Exec["Stop container ${name}"],
      }

    }
  }

}