# @summary PRIVATE CLASS - do not use directly
#
# @api private
#
class puppetdb::server::global (
  Stdlib::Absolutepath    $confdir         = $puppetdb::confdir,
  String                  $puppetdb_group  = $puppetdb::puppetdb_group,
  String                  $puppetdb_user   = $puppetdb::puppetdb_user,
  Stdlib::Absolutepath    $vardir          = $puppetdb::vardir,
) {
  # Debug params
  $debug_global = @("EOC"/)
    \n
      Puppetdb::Server::Global params

                                          confdir: ${confdir}
                                   puppetdb_group: ${puppetdb_group}
                                    puppetdb_user: ${puppetdb_user}
                                           vardir: ${vardir}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  #notify { "DEBUG_server_global: ${debug_global}": }

  $config_ini = "${confdir}/config.ini"

  file { $config_ini:
    ensure => file,
    owner  => $puppetdb_user,
    group  => $puppetdb_group,
    mode   => '0600',
  }

  # Set the defaults
  Ini_setting {
    path    => $config_ini,
    ensure  => 'present',
    section => 'global',
    require => File[$config_ini],
  }

  if $vardir {
    ini_setting { 'puppetdb_global_vardir':
      setting => 'vardir',
      value   => $vardir,
    }
  }
}
