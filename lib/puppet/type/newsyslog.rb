# Things that might occur in a newsyslog.conf file.
require 'puppet/parameter/boolean'

Puppet::Type.newtype(:newsyslog) do
  @doc = "Manage the configuration file for newsyslog(8)."

  ensurable
  newparam(:name, :namevar => true) do
    desc "The absoute path of the log file which is being rotated, when
	record_type is 'log', or (when record_type is 'include') the
	absolute path of the file to be included or a glob(3) expression
	that matches the absolute paths of multiple files to be included,
	as determined by the record_type parameter."
  end

  newparam(:record_type) do
    desc "The type of newsyslog.conf entry this is (log or include)."
    newvalues :text, :comment, :log, :include
  end

  newproperty(:owner) do
    desc "The ownership which should be assigned for newly-created
	logs after rotation; may be undefined, in which case the default
	ownership is used instead.  (If owner is undefined, then group
	must also be undefined, but this is not checked.)"

    validate do |value|
      return true unless resource[:record_type] == :log
      return true if value == :absent or value.nil?
      return true unless value =~ /[.:]\s/
      Puppet::Util::Errors.fail "Invalid user #{value.inspect}"
    end
  end

  newproperty(:group) do
    desc "The group ownership which should be assigned for newly-created
	logs after rotation; may be undefined, in which case the default
	group ownership is used instead.  (If group is undefined, then owner
	must also be undefined, but this is not checked.)"

    validate do |value|
      return true unless resource[:record_type] == :log
      return true if value == :absent or value.nil?
      return true unless value =~ /[.:\s]/
      Puppet::Util::Errors.fail "Invalid group #{value.inspect}"
    end
  end

  newproperty(:mode) do
    # Treat this as a string rather than converting back and forth to
    # integer; that will make it easier if newsyslog ever supports
    # POSIX-style mode strings.
    desc "The mode which should be assigned for newly-created logs after
	rotation; must be specified in octal notation (with or without
	a leading '0')."
    defaultto '644'

    validate do |value|
      return true unless resource[:record_type] == :log
      unless value.is_a?(String)
        Puppet::Util::Errors.fail "Mode must be a string (sorry!), got #{value.class}"
      end
      return true if value =~ /^[0-7]+$/
      Puppet::Util::Errors.fail "Invalid mode #{value.inspect}"
    end
  end

  newproperty(:max_size) do
    desc "The maximum size a log file should be allowed to grow before
	being rotated.  Must be a decimal integer (interpreted as kibibytes)
	or undefined.  At least one of max_size and rotation_schedule must
	be specified."
    defaultto do nil; end
    validate do |value|
      return true unless resource[:record_type] == :log
      return true if value == nil or value.is_a?(Integer)
      return true if value =~ /^[[:digit:]]$/
      Puppet::Util::Errors.fail "Invalid maximum size #{value.inspect}"
    end
  end

  newproperty(:keep_old_files) do
    desc "The number of old log files which should be kept."
    defaultto :missing
    validate do |value|
      return true unless resource[:record_type] == :log
      return true if value.is_a?(Integer) || value =~ /^[[:digit:]]$/
      Puppet::Util::Errors.fail "Invalid number of old files #{value.inspect}"
    end
  end

  newproperty(:rotation_schedule) do
    desc "The time at which the log file should be rotated.  Can be
	specified in three different ways: as a integer count of days
	since the last rotation, as an '@' sign followed by a modified ISO
	8601 date-and-time string (with parts omitted), or as a '$' sign
	followed by a week and day-of-week specification.  The schedule may
	be left undefined, in which case the rotation is done solely on the
	basis of file size.  At least one of rotation_schedule and max_size
	must be specified."
    defaultto do nil; end
    validate do |value|
      return true unless resource[:record_type] == :log
      return true if value.nil?
      return true unless value =~ /[[:space:]]/
      Puppet::Util::Errors.fail "Invalid rotation schedule #{value.inspect}"
    end
  end

  newproperty(:flags) do
    desc "Various flags that should be handled separately."
    defaultto '-'
    validate do |value|
      return true unless resource[:record_type] == :log
      return true if value =~ /^(?:-|[A-Za-z]+)$/
    end
  end

  newproperty(:pid_file) do
    desc "The absolute path of a file containing the process ID of
	a daemon to notify after the log is rotated.  If undefined,
	a signal will be sent to syslogd(8)."
    validate do |value|
      return true unless resource[:record_type] == :log
      return true if value == :absent or value.nil?
      return true if value[0] == '/' and value !~ /[[:space:]]/
      Puppet::Util::Errors.fail "Invalid PID file #{value.inspect}"
    end
  end

  newproperty(:signal) do
    # XXX ought to allow symbols but no good way to translate to
    # numbers
    desc "The signal to be sent to the process being notified about the
	log rotation, as an integer.  If undefined, a SIGHUP is sent."
    validate do |value|
      return true unless resource[:record_type] == :log
      return true if value == :absent or value.nil? or value.is_a?(Integer)
      return true if value =~ /^[[:digit:]]$/
      Puppet::Util::Errors.fail "Invalid signal number #{value.inspect}"
    end
  end

  newparam(:target) do
    desc "The newsyslog(8) configuration file, if not /etc/newsyslog.conf."
    defaultto do
      @resource.class.defaultprovider.default_target
    end
  end
end
