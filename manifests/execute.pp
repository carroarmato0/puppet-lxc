define lxc::execute (
  $container,
  $command,
){

  $title_hash = md5("${container}: ${title}")

  exec { "${container}: ${title}":
    command   => "lxc-attach -n ${container} -- ${command}",
    path      => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    creates   => "${lxc::params::containerdir}/${container}/.${title_hash}",
    onlyif    => "lxc-info -n ${container} | grep -c RUNNING",
    logoutput => true,
  }

  file { "${lxc::params::containerdir}/${container}/.${title_hash}":
    ensure  => file,
    mode    => '0644',
    content => "### Managed by Puppet ###\nThis is a lock file for the execution of \"${title}\"\n",
    require => Exec["${container}: ${title}"],
  }

}
