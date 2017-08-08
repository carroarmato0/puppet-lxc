class lxc::config {

  ## Basic folders
  file { '/usr/share/lxc':
    ensure => directory,
  }
  file { '/etc/lxc':
    ensure => directory,
  }
  file { '/etc/lxc/ovs/':
    ensure  => directory,
    recurse => true,
    purge   => true,
  }
  file { '/etc/lxc/auto':
    ensure  => directory,
    recurse => true,
    purge   => true,
    require => File['/etc/lxc'],
  }
  file { '/var/lib/lxc':
    ensure        => directory,
    purge         => true,
    recurse       => true,
    recurselimit  => 0,
  }

  ## Functions
  file { '/usr/share/lxc/lxc.functions':
    ensure  => file,
    content => template('lxc/lxc.functions.erb'),
    require => File['/usr/share/lxc'],
  }

  ## /etc/lxc/default.conf
  file { '/etc/lxc/default.conf':
    ensure  => file,
    content => template('lxc/default.conf.erb'),
    require => File['/etc/lxc'],
  }

}
