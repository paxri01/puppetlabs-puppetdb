# @summary Class for configuring SSL connection for the PuppetDB postgresql database.
#
# @see README.md for more information.
#
class puppetdb::database::ssl_configuration {
  $create_read_user_rule       = $puppetdb::create_read_user_rule
  $database_name               = $puppetdb::database_name
  $database_username           = $puppetdb::database_username
  $postgresql_ssl_ca_cert_path = $puppetdb::postgresql_ssl_ca_cert_path
  $postgresql_ssl_cert_path    = $puppetdb::postgresql_ssl_cert_path
  $postgresql_ssl_key_path     = $puppetdb::postgresql_ssl_key_path
  $puppetdb_server             = $puppetdb::puppetdb_server
  $read_database_host          = $puppetdb::read_database_host
  $read_database_username      = $puppetdb::read_database_username

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

  if $create_read_user_rule {
    puppetdb::database::postgresql_ssl_rules { "Configure postgresql ssl rules for ${read_database_username}":
      database_name     => $database_name,
      database_username => $read_database_username,
      puppetdb_server   => $puppetdb_server,
    }
  }
}
