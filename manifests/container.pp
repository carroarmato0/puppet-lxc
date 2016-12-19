define lxc::container (
  $template,
  $ensure           = 'present',
  $vgname           = $lxc::params::vgname,
  $fstype           = $lxc::params::fstype,
  $fssize           = $lxc::params::fssize,
  $backingstore     = 'none',
  $autostart        = true,
  $enable_ovs       = $lxc::enable_ovs,
  $network_type     = $lxc::network_type,
  $network_link     = $lxc::network_link,
  $network_flags    = $lxc::network_flags,
  $bridge           = $lxc::bridge,
  $extra_config     = {},
  $execute_commands = {},
){

  include lxc

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  if $autostart {
    file { "/etc/lxc/auto/${name}.conf":
      ensure  => link,
      target  => "${lxc::params::containerdir}/${name}/config",
      require => File['/etc/lxc/auto'],
    }
  }

  case $ensure {
    'present', 'install': {
      case $backingstore {
        'lvm': {
          exec { "Create_a_${template}_container_${name}_with_LVM_backend_${vgname}_volume_group_${fstype}_FS_and_${fssize}_big":
            command => "lxc-create -n ${name} -t ${template} -B lvm --vgname=${vgname} --fstype=${fstype} --fssize=${fssize}",
            before  => Exec["Start_container_${name}"],
            unless  => "test -f ${lxc::params::containerdir}/${name}/config",
          }
        }
        'loop': {
          exec { "Create_a_${template}_container_${name}_with_loop":
            command => "lxc-create -n ${name} -t ${template} -B loop",
            before  => Exec["Start_container_${name}"],
            unless  => "test -f ${lxc::params::containerdir}/${name}/config",
          }
        }
        'btrfs': {
          exec { "Create_a_${template}_container_${name}_with_btrfs":
            command => "lxc-create -n ${name} -t ${template} -B btrfs",
            before  => Exec["Start_container_${name}"],
            unless  => "test -f ${lxc::params::containerdir}/${name}/config",
          }
        }
        'none', default: {
          exec { "Create_a_${template}_container_${name}_with_minimal_defaults":
            command => "lxc-create -n ${name} -t ${template}",
            before  => Exec["Start_container_${name}"],
            unless  => "test -f ${lxc::params::containerdir}/${name}/config",
          }
        }
      }

      exec { "Start_container_${name}":
        command => "lxc-start -d -n ${name}",
        onlyif  => "lxc-info -n ${name} | grep -c STOPPED",
        require => File["${lxc::params::containerdir}/${name}/config"],
      }

      file { "${lxc::params::containerdir}/${name}/config":
        ensure  => file,
        mode    => '0644',
        content => template('lxc/container.erb'),
      }

      if !empty($execute_commands) {
        $defaults_exec = {
          'container' => $name,
        }
        create_resources('lxc::execute', $execute_commands, $defaults_exec)
      }

    }
    'stopped', 'shutdown', 'halted': {
      exec { "Stop_container_${name}":
        command => "lxc-stop -n ${name}",
        onlyif  => "lxc-info -n ${name} | grep -c RUNNING",
      }
    }
    'purge','delete','destroy','absent': {
      exec { "Purge_container_${name}":
        command => "lxc-stop -n ${name} && lxc-destroy -n ${name}",
        onlyif  => "test -f ${lxc::params::containerdir}/${name}/config",
      }

    }
  }

}
