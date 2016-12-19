define lxc::execute (
  $container,
  $command,
  $logoutput = 'on_failure',
  $recurring = false,
){

  $title_hash = md5("${container}: ${title}")

  if $recurring {
    exec { "${container}: ${title}":
      command   => "lxc-attach -n ${container} -- ${command}",
      path      => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      onlyif    => "lxc-info -n ${container} | grep -c RUNNING",
      logoutput => $logoutput,
    }
  } else {
    exec { "${container}: ${title}":
      command   => "lxc-attach -n ${container} -- ${command}",
      path      => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      creates   => "${lxc::params::containerdir}/${container}/locks/${title_hash}",
      onlyif    => "lxc-info -n ${container} | grep -c RUNNING",
      logoutput => $logoutput,
    }

    file { "${lxc::params::containerdir}/${container}/locks/${title_hash}":
      ensure  => file,
      mode    => '0644',
      content => "### Managed by Puppet ###\nThis is a lock file for the execution of \"${title}\"\n",
      require => Exec["${container}: ${title}"],
    }
  }

}
