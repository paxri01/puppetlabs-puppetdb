# @summay PRIVATE CLASS - do not use directly
#
# @api private
#
class puppetdb::server::command_processing (
  Optional[String]      $command_threads    = undef,
  Optional[String]      $concurrent_writes  = undef,
  Stdlib::Absolutepath  $confdir            = $puppetdb::params::confdir,
  Optional[String]      $store_usage        = undef,
  Optional[String]      $temp_usage         = undef,
) {
  # Debug params
  $debug_command_processing = @("EOC"/)
    \n
      Puppetdb::Server::Command_processing params

                                  command_threads: ${command_threads}
                                concurrent_writes: ${concurrent_writes}
                                          confdir: ${confdir}
                                      store_usage: ${store_usage}
                                       temp_usage: ${temp_usage}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  notify { "DEBUG_command_processing: ${debug_command_processing}": }

  $config_ini = "${confdir}/config.ini"

  # Set the defaults
  Ini_setting {
    path    => $config_ini,
    ensure  => 'present',
    section => 'command-processing',
    require => File[$config_ini],
  }

  if $command_threads {
    ini_setting { 'puppetdb_command_processing_threads':
      setting => 'threads',
      value   => $command_threads,
    }
  } else {
    ini_setting { 'puppetdb_command_processing_threads':
      ensure  => 'absent',
      setting => 'threads',
    }
  }

  if $concurrent_writes {
    ini_setting { 'puppetdb_command_processing_concurrent_writes':
      setting => 'concurrent-writes',
      value   => $concurrent_writes,
    }
  } else {
    ini_setting { 'puppetdb_command_processing_concurrent_writes':
      ensure  => 'absent',
      setting => 'concurrent-writes',
    }
  }

  if $store_usage {
    ini_setting { 'puppetdb_command_processing_store_usage':
      setting => 'store-usage',
      value   => $store_usage,
    }
  } else {
    ini_setting { 'puppetdb_command_processing_store_usage':
      ensure  => 'absent',
      setting => 'store-usage',
    }
  }

  if $temp_usage {
    ini_setting { 'puppetdb_command_processing_temp_usage':
      setting => 'temp-usage',
      value   => $temp_usage,
    }
  } else {
    ini_setting { 'puppetdb_command_processing_temp_usage':
      ensure  => 'absent',
      setting => 'temp-usage',
    }
  }
}
