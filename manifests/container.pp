define lxc::container (
  $template,
  $ensure       = 'present',
  $vgname       = $lxc::params::vgname,
  $fstype       = $lxc::params::fstype,
  $fssize       = $lxc::params::fssize,
  $backingstore = 'none',
  $autostart    = true,
){

  include lxc

  $conf_path = '/var/lib/lxc'

  #validate_re($template, $lxc::params::supported_templates,'Template not supported')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  #file { "${conf_path}/${name}":
  #  ensure => directory,
  #}

  #file { "/var/lib/lxc/${name}/config":
  #  ensure => file,
  #}

  if $autostart {
    file { "/etc/lxc/auto/${name}.conf":
      ensure  => link,
      target  => "${conf_path}/${name}/config",
      require => File['/etc/lxc/auto'],
    }
  }

  exec { "Stop_container_${name}":
    command     => "lxc-stop -n ${name}",
    unless      => "lxc-ls --stopped $name",
    refreshonly => true,
  }

  case $ensure {
    'present', 'install': {
      case $backingstore {
        'lvm': {
          exec { "Create_a_${template}_container_${name}_with_LVM_backend_${vgname}_volume_group_${fstype}_FS_and_${fssize}_big":
            command => "lxc-create -n ${name} -t ${template} -B lvm --vgname=${vgname} --fstype=${fstype} --fssize=${fssize}",
            before  => Exec["Start_container_${name}"],
            unless  => "test -f ${conf_path}/${name}/config",
          }
        }
        'loop': {
          exec { "Create_a_${template}_container_${name}_with_loop":
            command => "lxc-create -n ${name} -t ${template} -B loop",
            before  => Exec["Start_container_${name}"],
            unless  => "test -f ${conf_path}/${name}/config",
          }
        }
        'btrfs': {
          exec { "Create_a_${template}_container_${name}_with_btrfs":
            command => "lxc-create -n ${name} -t ${template} -B btrfs",
            before  => Exec["Start_container_${name}"],
            unless  => "test -f ${conf_path}/${name}/config",
          }
        }
        'none', default: {
          exec { "Create_a_${template}_container_${name}_with_minimal_defaults":
            command => "lxc-create -n ${name} -t ${template}",
            before  => Exec["Start_container_${name}"],
            unless  => "test -f ${conf_path}/${name}/config",
          }
        }
      }

      exec { "Start_container_${name}":
        command => "lxc-start -d -n ${name}",
        onlyif  => "test ! -z `lxc-ls --stopped ${name}`",
      }
    }
    'stopped', 'shutdown', 'halted': {
      exec { "Stop_container_${name}":
        command => "lxc-stop -n ${name}",
        onlyif  => "test ! -z `lxc-ls --running ${name}`",
      }
    }
    'purge','delete','destroy','absent': {
      exec { "Purge_container_${name}":
        command => "lxc-stop -n ${name} && lxc-destroy -n ${name}",
        onlyif  => "test -f ${conf_path}/${name}/config",
      }

    }
  }

}

