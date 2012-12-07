# From http://projects.puppetlabs.com/projects/1/wiki/Puppet_Free_Bsd
# but altered to edit /etc/rc.conf instead of /etc/rc.conf.local
define freebsd::rc_conf($ensure, $value) {
  shell_config { "rc_conf_${name}":
    file => "/etc/rc.conf",
    key => $name,
    value => $value,
    ensure => $ensure,
  }
}
