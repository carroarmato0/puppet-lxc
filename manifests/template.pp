define lxc::template (
  $templatedir,
  $template = $name,
) {

  if !defined(File["$templatedir"]) {
    file { $templatedir:
      ensure => directory,
    }
  }

  file {"${templatedir}/lxc-${template}":
    ensure  => file,
    content => template("lxc/containers/lxc-${template}.erb"),
    require => File["${templatedir}"],
  }

}
