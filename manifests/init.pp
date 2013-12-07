class lxc (
  $templatedir  = $lxc::params::templatedir,
  $network_type = $lxc::params::network_type,
  $network_link = $lxc::params::network_link,
) inherits lxc::params {

  include lxc::package
  #include lxc::service

  ## Basic folders
  file { '/usr/share/lxc':
    ensure => directory,
  }
  file { '/etc/lxc':
    ensure => directory,
  }
  file { '/etc/lxc/auto':
    ensure  => directory,
    recurse => true,
    purge   => true,
    require => File['/etc/lxc'],
  }
  file { '/var/lib/lxc':
    ensure => directory,
  }

  ## Templates
  #lxc::template {$lxc::params::supported_templates:
  #  templatedir => $templatedir,
  #}

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
