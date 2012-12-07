# From http://projects.puppetlabs.com/projects/1/wiki/Puppet_Free_Bsd
define freebsd::periodic_conf($ensure, $value) {
  shell_config {  "periodic_conf_${name}":
    file => '/etc/periodic.conf',
    key => $name,
    value => $value,
    ensure => $ensure
  }
}
