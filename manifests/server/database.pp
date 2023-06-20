# @summary PRIVATE CLASS - do not use directly
#
# @api private
#
class puppetdb::server::database (
  Stdlib::Absolutepath           $confdir                           = $puppetdb::params::confdir,
  String                         $conn_keep_alive                   = '45',
  String                         $conn_lifetime                     = '0',
  String                         $conn_max_age                      = '60',
  String                         $database                          = 'postgres',
  Stdlib::Absolutepath           $database_embedded_path            = $puppetdb::params::database_embedded_path,
  Stdlib::Host                   $database_host                     = 'localhost',
  Optional[String]               $database_max_pool_size            = undef,
  String                         $database_name                     = 'puppetdb',
  String                         $database_password                 = 'puppetdb',
  Stdlib::Port                   $database_port                     = 5432,
  String                         $database_username                 = 'puppetdb',
  Boolean                        $database_validate                 = true,
  Optional[Array]                $facts_blacklist                   = undef,
  String                         $gc_interval                       = '60',
  Optional[String]               $jdbc_ssl_properties               = undef,
  String                         $log_slow_statements               = '10',
  Boolean                        $manage_db_password                = true,
  Boolean                        $migrate                           = true,
  String                         $node_purge_gc_batch_limit         = '25',
  String                         $node_purge_ttl                    = '14d',
  String                         $node_ttl                          = '7d',
  Boolean                        $postgresql_ssl_on                 = false,
  String                         $puppetdb_group                    = $puppetdb::params::puppetdb_group,
  String                         $puppetdb_user                     = $puppetdb::params::puppetdb_user,
  String                         $report_ttl                        = '14d',
  Stdlib::Absolutepath           $ssl_ca_cert_path                  = $puppetdb::params::ssl_ca_cert_path,
  Stdlib::Absolutepath           $ssl_cert_path                     = $puppetdb::params::ssl_cert_path,
  Stdlib::Absolutepath           $ssl_key_pk8_path                  = $puppetdb::params::ssl_key_pk8_path,
) inherits puppetdb::params {
  # Debug params
  $debug_database = @("EOC"/)
    \n
      puppetdb::server::database params

                                          confdir: ${confdir}
                                  conn_keep_alive: ${conn_keep_alive}
                                    conn_lifetime: ${conn_lifetime}
                                     conn_max_age: ${conn_max_age}
                                         database: ${database}
                           database_embedded_path: ${database_embedded_path}
                                    database_host: ${database_host}
                           database_max_pool_size: ${database_max_pool_size}
                                    database_name: ${database_name}
                                database_password: ${database_password}
                                    database_port: ${database_port}
                                database_username: ${database_username}
                                database_validate: ${database_validate}
                                  facts_blacklist: ${facts_blacklist}
                                      gc_interval: ${gc_interval}
                              jdbc_ssl_properties: ${jdbc_ssl_properties}
                              log_slow_statements: ${log_slow_statements}
                               manage_db_password: ${manage_db_password}
                                          migrate: ${migrate}
                        node_purge_gc_batch_limit: ${node_purge_gc_batch_limit}
                                   node_purge_ttl: ${node_purge_ttl}
                                         node_ttl: ${node_ttl}
                                postgresql_ssl_on: ${postgresql_ssl_on}
                                   puppetdb_group: ${puppetdb_group}
                                    puppetdb_user: ${puppetdb_user}
                                       report_ttl: ${report_ttl}
                                 ssl_ca_cert_path: ${ssl_ca_cert_path}
                                    ssl_cert_path: ${ssl_cert_path}
                                 ssl_key_pk8_path: ${ssl_key_pk8_path}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  notify { "DEBUG_server_database: ${debug_database}": }

  if str2bool($database_validate) {
    # Validate the database connection.  If we can't connect, we want to fail
    # and skip the rest of the configuration, so that we don't leave puppetdb
    # in a broken state.
    #
    # NOTE:
    # Because of a limitation in the postgres module this will break with
    # a duplicate declaration if read and write database host+name are the
    # same.
    class { 'puppetdb::server::validate_db':
      database          => $database,
      database_host     => $database_host,
      database_port     => $database_port,
      database_username => $database_username,
      database_password => $database_password,
      database_name     => $database_name,
    }
  }

  $database_ini = "${confdir}/database.ini"

  file { $database_ini:
    ensure => file,
    owner  => $puppetdb_user,
    group  => $puppetdb_group,
    mode   => '0600',
  }

  $file_require = File[$database_ini]
  $ini_setting_require = str2bool($database_validate) ? {
    false   => $file_require,
    default => [$file_require, Class['puppetdb::server::validate_db']],
  }
  # Set the defaults
  Ini_setting {
    path    => $database_ini,
    ensure  => present,
    section => 'database',
    require => $ini_setting_require,
  }

  case $database {
    'embedded': {
      $classname = 'org.hsqldb.jdbcDriver'
      $subprotocol = 'hsqldb'
      $subname = "file:${database_embedded_path};hsqldb.tx=mvcc;sql.syntax_pgs=true"
    }
    'postgres': {
      $classname = 'org.postgresql.Driver'
      $subprotocol = 'postgresql'

      if !empty($jdbc_ssl_properties) {
        $database_suffix = $jdbc_ssl_properties
      } else {
        $database_suffix = ''
      }

      $subname_default = "//${database_host}:${database_port}/${database_name}${database_suffix}"

      if $postgresql_ssl_on and !empty($jdbc_ssl_properties) {
        fail("Variables 'postgresql_ssl_on' and 'jdbc_ssl_properties' can not be used at the same time!")
      }

      if $postgresql_ssl_on {
        $subname = @("EOT"/L)
          ${subname_default}?\
          ssl=true&sslfactory=org.postgresql.ssl.LibPQFactory&\
          sslmode=verify-full&sslrootcert=${ssl_ca_cert_path}&\
          sslkey=${ssl_key_pk8_path}&sslcert=${ssl_cert_path}\
          | EOT
      } else {
        $subname = $subname_default
      }

      ##Only setup for postgres
      ini_setting { 'puppetdb_psdatabase_username':
        setting => 'username',
        value   => $database_username,
      }

      if $database_password != undef and $manage_db_password {
        ini_setting { 'puppetdb_psdatabase_password':
          setting => 'password',
          value   => $database_password,
        }
      }
    }
    default: { fail("Unsupported database type: ${database}") }
  }

  ini_setting { 'puppetdb_classname':
    setting => 'classname',
    value   => $classname,
  }

  ini_setting { 'puppetdb_subprotocol':
    setting => 'subprotocol',
    value   => $subprotocol,
  }

  ini_setting { 'puppetdb_pgs':
    setting => 'syntax_pgs',
    value   => true,
  }

  ini_setting { 'puppetdb_subname':
    setting => 'subname',
    value   => $subname,
  }

  ini_setting { 'puppetdb_gc_interval':
    setting => 'gc-interval',
    value   => $gc_interval,
  }

  ini_setting { 'puppetdb_node_purge_gc_batch_limit':
    setting => 'node-purge-gc-batch-limit',
    value   => $node_purge_gc_batch_limit,
  }

  ini_setting { 'puppetdb_node_ttl':
    setting => 'node-ttl',
    value   => $node_ttl,
  }

  ini_setting { 'puppetdb_node_purge_ttl':
    setting => 'node-purge-ttl',
    value   => $node_purge_ttl,
  }

  ini_setting { 'puppetdb_report_ttl':
    setting => 'report-ttl',
    value   => $report_ttl,
  }

  ini_setting { 'puppetdb_log_slow_statements':
    setting => 'log-slow-statements',
    value   => $log_slow_statements,
  }

  ini_setting { 'puppetdb_conn_max_age':
    setting => 'conn-max-age',
    value   => $conn_max_age,
  }

  ini_setting { 'puppetdb_conn_keep_alive':
    setting => 'conn-keep-alive',
    value   => $conn_keep_alive,
  }

  ini_setting { 'puppetdb_conn_lifetime':
    setting => 'conn-lifetime',
    value   => $conn_lifetime,
  }

  ini_setting { 'puppetdb_migrate':
    setting => 'migrate',
    value   => $migrate,
  }

  if $puppetdb::params::database_max_pool_size_setting_name != undef {
    if $database_max_pool_size == 'absent' {
      ini_setting { 'puppetdb_database_max_pool_size':
        ensure  => absent,
        setting => $puppetdb::params::database_max_pool_size_setting_name,
      }
    } elsif $database_max_pool_size != undef {
      ini_setting { 'puppetdb_database_max_pool_size':
        setting => $puppetdb::params::database_max_pool_size_setting_name,
        value   => $database_max_pool_size,
      }
    }
  }

  if ($facts_blacklist) and length($facts_blacklist) != 0 {
    $joined_facts_blacklist = join($facts_blacklist, ', ')
    ini_setting { 'puppetdb_facts_blacklist':
      setting => 'facts-blacklist',
      value   => $joined_facts_blacklist,
    }
  } else {
    ini_setting { 'puppetdb_facts_blacklist':
      ensure  => absent,
      setting => 'facts-blacklist',
    }
  }
}
