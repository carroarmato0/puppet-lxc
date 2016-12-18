class lxc::package {

  package {'lxc':
    ensure => present,
  }

  package { $::lxc::params::extra_packages:
    ensure => installed,
  }

}
