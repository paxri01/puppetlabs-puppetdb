# @summary Class for configuring SSL connection for the PuppetDB postgresql database.
#
# @see README.md for more information.
#
# @param create_read_user_rule
#   Boolean to create ssl connection for the read user.
# @param database_name
#   The name of the database instance to connect to. Defaults to 'puppetdb', ignored
#   for 'embedded' database.
# @param database_username
#   The name of the database user to connect as. Defaults to 'puppetdb', ignored for
#   'embedded' database.
# @param postgresql_ssl_ca_cert_path
# @param postgresql_ssl_cert_path
# @param postgresql_ssl_key_path
# @param puppetdb_server
#   The dns name or ip of the PuppetDB server. Defaults to the hostname of the current node,
#   i.e. '$facts['networking']['fqdn']'.
# @param read_database_host
#   *This parameter must be set to use another PuppetDB instance for queries.*
#
#   The hostname or IP address of the read database server. If set to 'undef', and
#   'manage_database' is set to 'true', it will use the value of the 'database_host'
#   parameter. This option is supported in PuppetDB >= 1.6.
# @param read_database_username
#   The name of the read database user to connect as. Defaults to 'puppetdb-read'.
#   This option is supported in PuppetDB >= 1.6.
#
class puppetdb::database::ssl_configuration (
  Boolean                $create_read_user_rule        = undef,
  String                 $database_name                = 'puppetdb',
  String                 $database_username            = 'puppetdb',
  Stdlib::Absolutepath   $postgresql_ssl_ca_cert_path  = $puppetdb::params::postgresql_ssl_ca_cert_path,
  Stdlib::Absolutepath   $postgresql_ssl_cert_path     = $puppetdb::params::postgresql_ssl_cert_path,
  Stdlib::Absolutepath   $postgresql_ssl_key_path      = $puppetdb::params::postgresql_ssl_key_path,
  Stdlib::Host           $puppetdb_server              = fact('networking.fqdn'),
  Optional[String]       $read_database_host           = undef,
  String                 $read_database_username       = 'puppetdb-read',
) {
  # Debug params
  $debug_ssl_configuration = @("EOC"/)
    \n
      Puppetdb::Database::Ssl_configuration params

                            create_read_user_rule: ${create_read_user_rule}
                                    database_name: ${database_name}
                                database_username: ${database_username}
                      postgresql_ssl_ca_cert_path: ${postgresql_ssl_ca_cert_path}
                         postgresql_ssl_cert_path: ${postgresql_ssl_cert_path}
                          postgresql_ssl_key_path: ${postgresql_ssl_key_path}
                                  puppetdb_server: ${puppetdb_server}
                               read_database_host: ${read_database_host}
                           read_database_username: ${read_database_username}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  notify { "DEBUG_database_postgresql: ${debug_ssl_configuration}": }

  File {
    ensure  => 'present',
    owner   => 'postgres',
    mode    => '0600',
    require => Package['postgresql-server'],
  }

  file { 'postgres private key':
    path   => "${postgresql::server::datadir}/server.key",
    source => $postgresql_ssl_key_path,
    owner  => 'postgres',
    group  => 'postgres',
    mode   => '0600',
  }

  file { 'postgres public key':
    path   => "${postgresql::server::datadir}/server.crt",
    source => $postgresql_ssl_cert_path,
    owner  => 'postgres',
    group  => 'postgres',
    mode   => '0644',
  }

  postgresql::server::config_entry { 'ssl':
    ensure  => 'present',
    value   => 'on',
    require => [File['postgres private key'], File['postgres public key']],
  }

  postgresql::server::config_entry { 'ssl_cert_file':
    ensure  => 'present',
    value   => "${postgresql::server::datadir}/server.crt",
    require => [File['postgres private key'], File['postgres public key']],
  }

  postgresql::server::config_entry { 'ssl_key_file':
    ensure  => 'present',
    value   => "${postgresql::server::datadir}/server.key",
    require => [File['postgres private key'], File['postgres public key']],
  }

  postgresql::server::config_entry { 'ssl_ca_file':
    ensure  => 'present',
    value   => $postgresql_ssl_ca_cert_path,
    require => [File['postgres private key'], File['postgres public key']],
  }

  puppetdb::database::postgresql_ssl_rules { "Configure postgresql ssl rules for ${database_username}":
    database_name     => $database_name,
    database_username => $database_username,
    puppetdb_server   => $puppetdb_server,
  }

  if $create_read_user_rule == true {
    puppetdb::database::postgresql_ssl_rules { "Configure postgresql ssl rules for ${read_database_username}":
      database_name     => $database_name,
      database_username => $read_database_username,
      puppetdb_server   => $puppetdb_server,
    }
  }
}
