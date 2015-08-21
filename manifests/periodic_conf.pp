#
# freebsd::periodic_conf defines things in /etc/periodic.conf, which
# controls the operation of periodic(8) (run hourly, daily, weekly, and
# monthly for different tasks from cron).  If ENSURE is set to
# present (the default), then the periodic.conf setting SETTING will be
# defined to VALUE.  If ENSURE is set to 'absent' or 'purged', then
# SETTING will be unset (restoring the default behavior).  SETTING defaults
# to the name of the resource.
# 
define freebsd::periodic_conf($setting = $name, $ensure = 'present',
			      $value = undef) {
  if $ensure == 'present' {
    validate_string($value)
  }
  shell_config {  "periodic_conf_${name}":
    file => '/etc/periodic.conf',
    key => $setting,
    value => $value,
    ensure => $ensure
  }
}
