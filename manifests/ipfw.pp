# Simple module to manage basic configuration of FreeBSD's standard
# firewall, ipfw.  If type is set to a pathname, a file resource must be
# defined for that file (since many different methods might be used to
# construct the file, and as it's not required if you just want a normal
# "open" configuration, we don't define that resource here.
class freebsd::ipfw ($ensure = 'present', $type = 'open') {
  service {'firewall':
    name       => 'ipfw',
    enable     => $ensure == 'present',
    hasstatus  => false,
    hasrestart => true,
  }
  if $type =~ /^\// {
    Service['firewall'] {
      require   => File[$type],
      subscribe => File[$type],
    }
  }
  freebsd::rc_conf {'firewall_type': value => $type, ensure => $ensure, }
}
