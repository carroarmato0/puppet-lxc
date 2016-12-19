class lxc (
  $templatedir   = $lxc::params::templatedir,
  $network_type  = $lxc::params::network_type,
  $network_link  = $lxc::params::network_link,
  $network_flags = $lxc::params::network_flags,
  $enable_ovs    = false,
  $bridge        = undef,
) inherits lxc::params {

  include lxc::package
  include lxc::config

}
