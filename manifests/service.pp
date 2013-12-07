class lxc::service {

  service { 'lxc-net':
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => Class["lxc"],
  }

}