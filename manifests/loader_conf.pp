# From http://projects.puppetlabs.com/projects/1/wiki/Puppet_Free_Bsd
# but altered to edit /boot/loader.conf instead of /etc/rc.conf.local
define freebsd::loader_conf($ensure, $value) {
  shell_config { "loader_conf_${name}":
    file => "/boot/loader.conf",
    key => $name,
    value => $value,
    ensure => $ensure,
  }
}
