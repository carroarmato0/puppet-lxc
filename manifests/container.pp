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
          exec { "Create a ${template} container ${name} with LVM backend ${vgname} volume group ${fstype} FS_and ${fssize} big":
            command => "lxc-create -n ${name} -t ${template} -B lvm --vgname=${vgname} --fstype=${fstype} --fssize=${fssize}",
            before  => Exec["Start container: ${name}"],
            unless  => "test -f ${lxc::params::containerdir}/${name}/config",
          }
        }
        'loop': {
          exec { "Create a ${template} container ${name} with loop":
            command => "lxc-create -n ${name} -t ${template} -B loop",
            before  => Exec["Start container: ${name}"],
            unless  => "test -f ${lxc::params::containerdir}/${name}/config",
          }
        }
        'btrfs': {
          exec { "Create a ${template} container ${name} with btrfs":
            command => "lxc-create -n ${name} -t ${template} -B btrfs",
            before  => Exec["Start container: ${name}"],
            unless  => "test -f ${lxc::params::containerdir}/${name}/config",
          }
        }
        'none', default: {
          exec { "Create a ${template} container ${name} with minimal defaults":
            command => "lxc-create -n ${name} -t ${template}",
            before  => Exec["Start container: ${name}"],
            unless  => "test -f ${lxc::params::containerdir}/${name}/config",
          }
        }
      }

      exec { "Start container: ${name}":
        command => "lxc-start -d -n ${name}",
        onlyif  => "lxc-info -n ${name} | grep -c STOPPED",
        require => File["${lxc::params::containerdir}/${name}/config"],
      }

      file { "${lxc::params::containerdir}/${name}/config":
        ensure  => file,
        mode    => '0644',
        content => template('lxc/container.erb'),
      }

      file { "${lxc::params::containerdir}/${name}/locks":
        ensure  => directory,
        mode    => '0644',
        purge   => true,
        recurse => true,
      }

      if !empty($execute_commands) {
        $defaults_exec = {
          'container' => $name,
        }
        create_resources('lxc::execute', $execute_commands, $defaults_exec)
      }

    }
    'stopped', 'shutdown', 'halted': {
      exec { "Stop container: ${name}":
        command => "lxc-stop -n ${name}",
        onlyif  => "lxc-info -n ${name} | grep -c RUNNING",
      }
    }
    'purge','delete','destroy','absent': {
      exec { "Purge container: ${name}":
        command => "lxc-stop -n ${name} && lxc-destroy -n ${name}",
        onlyif  => "test -f ${lxc::params::containerdir}/${name}/config",
      }

    }
  }

}
