class lxc::package {

  package {'lxc':
    ensure => present,
  }

  package {'debootstrap':
    ensure => present,
  }

  package {'cgroup-lite':
    ensure => present,
  }

}
