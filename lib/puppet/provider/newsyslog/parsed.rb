require 'puppet/provider/parsedfile'

Puppet::Type.type(:newsyslog).provide(:parsed, 
				      :parent => Puppet::Provider::ParsedFile,
				      :default_target => '/etc/newsyslog.conf',
				      :filetype => :flat) do
  desc "Parse and generate the configuration file for newsyslog(8),
	by default /etc/newsyslog.conf."

  text_line :comment, :match => /^\s*#/
  text_line :blank, :match => /^\s*$/

  FORMAT = %r/^(\/\S+)\s+(?:([^:.[:space:]]+)[:.](\S+)\s+)?([0-7]+)\s+(\d+)\s+(\*|\d+)\s+(\*|(?:@\d*T\d*)|(?:\$(?:[MW]\d*)?D\d*)|\d+)(?:\s+(-|[A-Za-z]+))?(?:\s+(\/\S+)(?:\s+(\d+))?)?\s*$/
  FIELDS = %w{name owner group mode keep_old_files max_size rotation_schedule
	      flags pid_file signal}

  record_line :log,
    :absent => :absent,
    :fields => FIELDS,
    :match => FORMAT,
    :to_line => proc {|h| Puppet::Type::Newsyslog::ProviderParsed.to_line(h) },
    :optional => %w{owner group flags pid_file signal}

  record_line :include,
    :absent => :absent,
    :fields => %w{name},
    :match => %r/^\s+<include>\s+(\S+)\s*$/,
    :to_line => proc {|h| Puppet::Type::Newsyslog::ProviderParsed.to_line(h) }

  def self.valid_ownership?(hash)
    hash[:owner] and hash[:group] and hash[:owner] != :absent and
	hash[:group] != :absent and hash[:owner] != 'absent' and
	hash[:group] != 'absent'
  end

  def self.to_line(hash)
    if [:blank, :comment].include?(hash[:record_type])
      # buggy puppet, passing us comment and blank lines as if they
      # were records
      return hash[:line]
    end

    # Include directives are easy.
    if hash[:record_type] == :include
      return '<include> ' + hash[:name]
   end

    if hash[:name].nil? or hash[:mode].nil? or hash[:keep_old_files].nil?
      raise Puppet::Error, "to_line: impossble #{hash.inspect}"
    end
    line = nil
    if self.valid_ownership?(hash)
      line = sprintf("%-23s %-15s ", hash[:name], 
		     hash[:owner] + ':' + hash[:group])
    else
      line = sprintf("%-39s ", hash[:name])
    end
    line += sprintf("%-4s %-5s %s\t%-6s %s", hash[:mode], hash[:keep_old_files],
		    hash[:max_size] || '*', hash[:rotation_schedule] || '*', 
		    (hash[:flags] and hash[:flags] != :absent) ? hash[:flags] : '-')
    line += ' ' + hash[:pid_file] if hash[:pid_file] and hash[:pid_file] != :absent
    line += ' ' + hash[:signal] if hash[:signal] and hash[:signal] != :absent
    line
  end
end
