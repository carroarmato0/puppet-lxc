define lxc::container (
  $template,
  $ensure           = 'present',
  $vgname           = $lxc::params::vgname,
  $fstype           = $lxc::params::fstype,
  $fssize           = $lxc::params::fssize,
  $backingstore     = 'none',
  $hwaddr           = '',
  $autostart        = $lxc::params::autostart,
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

  case $ensure {
    'present', 'install': {
      case $backingstore {
        'lvm': {
          exec { "Create a ${template} container ${name} with LVM backend ${vgname} volume group ${fstype} FS_and ${fssize} big":
            command => "lxc-create -n ${name} -t ${template} -B lvm --vgname=${vgname} --fstype=${fstype} --fssize=${fssize}",
            before  => Exec["Start container: ${name}"],
            alias   => "Create ${name}",
            unless  => "${lxc::params::lxc_list} | grep -c ${name}",
          }
        }
        'loop': {
          exec { "Create a ${template} container ${name} with loop":
            command => "lxc-create -n ${name} -t ${template} -B loop",
            before  => Exec["Start container: ${name}"],
            alias   => "Create ${name}",
            unless  => "${lxc::params::lxc_list} | grep -c ${name}",
          }
        }
        'btrfs': {
          exec { "Create a ${template} container ${name} with btrfs":
            command => "lxc-create -n ${name} -t ${template} -B btrfs",
            before  => Exec["Start container: ${name}"],
            alias   => "Create ${name}",
            unless  => "${lxc::params::lxc_list} | grep -c ${name}",
          }
        }
        'none', default: {
          exec { "Create a ${template} container ${name} with minimal defaults":
            command => "lxc-create -n ${name} -t ${template}",
            before  => Exec["Start container: ${name}"],
            alias   => "Create ${name}",
            unless  => "${lxc::params::lxc_list} | grep -c ${name}",
          }
        }
      }

      exec { "Start container: ${name}":
        command => "lxc-start -d -n ${name}",
        onlyif  => "lxc-info -n ${name} | grep -c STOPPED",
      }

      file { "${lxc::params::containerdir}/${name}":
        ensure  => directory,
        mode    => '0644',
      }

      file { "${lxc::params::containerdir}/${name}/locks":
        ensure  => directory,
        mode    => '0644',
        purge   => true,
        recurse => true,
        before  => Exec["Start container: ${name}"],
      }

      if $hwaddr != '' {
        file_line { "${name}: hwaddr":
          ensure  => present,
          path    => "${lxc::params::containerdir}/${name}/config",
          line    => "lxc.network.hwaddr = ${hwaddr}",
          require => Exec["Create ${name}"],
          before  => Exec["Start container: ${name}"],
        }
      } else {
        file_line { "${name}: hwaddr":
          ensure            => absent,
          path              => "${lxc::params::containerdir}/${name}/config",
          line              => "lxc.network.hwaddr = ${hwaddr}",
          match             => '^lxc.network.hwaddr\ =\ ',
          match_for_absence => true,
          require           => Exec["Create ${name}"],
          before            => Exec["Start container: ${name}"],
        }
      }

      if $autostart {
        file_line { "${name}: autostart":
          ensure  => present,
          path    => "${lxc::params::containerdir}/${name}/config",
          line    => "lxc.start.auto = 1",
          require => Exec["Create ${name}"],
          before  => Exec["Start container: ${name}"],
        }
      } else {
        file_line { "${name}: autostart":
          ensure            => absent,
          path              => "${lxc::params::containerdir}/${name}/config",
          line              => "lxc.start.auto = 1",
          match             => '^lxc.start.auto\ =\ ',
          match_for_absence => true,
          require           => Exec["Create ${name}"],
          before            => Exec["Start container: ${name}"],
        }
      }

      if !empty($execute_commands) {
        $defaults_exec = {
          'container' => $name,
          'require'   => Exec["Start container: ${name}"],
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
        command => "lxc-stop -n ${name}; lxc-destroy -n ${name}",
        onlyif  => "test -f ${lxc::params::containerdir}/${name}/config",
      }

    }
  }

  if $::enable_ovs {
    file { "/etc/lxc/${name}-ovsup":
      ensure  => file,
      mode    => '0655',
      content => template('lxc/ovsup.erb'),
    }
    file { "/etc/lxc/${name}-ovsdown":
      ensure  => file,
      mode    => '0655',
      content => template('lxc/ovsdown.erb'),
    }
  }

}
