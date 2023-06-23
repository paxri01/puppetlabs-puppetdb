# @summary PRIVATE CLASS - do not use directly
#
# @api private
#
class puppetdb::server::read_database (
  Stdlib::Absolutepath   $confdir                 = $puppetdb::confdir,
  String                 $conn_keep_alive         = $puppetdb::conn_keep_alive,
  String                 $conn_lifetime           = $puppetdb::conn_lifetime,
  String                 $conn_max_age            = $puppetdb::conn_max_age,
  Optional[String]       $database_max_pool_size  = $puppetdb::database_max_pool_size,
  Boolean                $database_validate       = $puppetdb::database_validate,
  Optional[String]       $jdbc_ssl_properties     = $puppetdb::jdbc_ssl_properties,
  String                 $log_slow_statements     = $puppetdb::log_slow_statements,
  Boolean                $manage_db_password      = $puppetdb::manage_db_password,
  Boolean                $postgresql_ssl_on       = $puppetdb::postgresql_ssl_on,
  String                 $puppetdb_group          = $puppetdb::puppetdb_group,
  String                 $puppetdb_user           = $puppetdb::puppetdb_user,
  String                 $read_database           = $puppetdb::read_database,
  Stdlib::Host           $read_database_host      = $puppetdb::read_database_host,
  String                 $read_database_name      = $puppetdb::read_database_name,
  String                 $read_database_password  = $puppetdb::read_database_password,
  Stdlib::Port           $read_database_port      = $puppetdb::read_database_port,
  String                 $read_database_username  = $puppetdb::read_database_username,
  Stdlib::Absolutepath   $ssl_ca_cert_path        = $puppetdb::ssl_ca_cert_path,
  Stdlib::Absolutepath   $ssl_cert_path           = $puppetdb::ssl_cert_path,
  Stdlib::Absolutepath   $ssl_key_pk8_path        = $puppetdb::ssl_key_pk8_path,
) {
  # Debug code
  $debug_read_database = @("EOC"/)
    \n
      Puppetdb::Server::Read_database params

                                          confdir: ${confdir}
                                   puppetdb_group: ${puppetdb_group}
                                    puppetdb_user: ${puppetdb_user}
                                  conn_keep_alive: ${conn_keep_alive}
                                    conn_lifetime: ${conn_lifetime}
                                     conn_max_age: ${conn_max_age}
                           database_max_pool_size: ${database_max_pool_size}
                                database_validate: ${database_validate}
                              jdbc_ssl_properties: ${jdbc_ssl_properties}
                              log_slow_statements: ${log_slow_statements}
                               manage_db_password: ${manage_db_password}
                                postgresql_ssl_on: ${postgresql_ssl_on}
                                   puppetdb_group: ${puppetdb_group}
                                    puppetdb_user: ${puppetdb_user}
                                    read_database: ${read_database}
                               read_database_host: ${read_database_host}
                               read_database_name: ${read_database_name}
                           read_database_password: ${read_database_password}
                               read_database_port: ${read_database_port}
                           read_database_username: ${read_database_username}
                                 ssl_ca_cert_path: ${ssl_ca_cert_path}
                                    ssl_cert_path: ${ssl_cert_path}
                                 ssl_key_pk8_path: ${ssl_key_pk8_path}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  #notify { "DEBUG_server_read_database: ${debug_read_database}": }

  if $read_database_host != undef {
    if str2bool($database_validate) {
      # Validate the database connection.  If we can't connect, we want to fail
      # and skip the rest of the configuration, so that we don't leave puppetdb
      # in a broken state.
      #
      # NOTE:
      # Because of a limitation in the postgres module this will break with
      # a duplicate declaration if read and write database host+name are the
      # same.
      class { 'puppetdb::server::validate_read_db':
        database          => $read_database,
        database_host     => $read_database_host,
        database_port     => $read_database_port,
        database_username => $read_database_username,
        database_password => $read_database_password,
        database_name     => $read_database_name,
      }
    }

    $read_database_ini = "${confdir}/read_database.ini"

    file { $read_database_ini:
      ensure => file,
      owner  => $puppetdb_user,
      group  => $puppetdb_group,
      mode   => '0600',
    }

    $file_require = File[$read_database_ini]
    $ini_setting_require = str2bool($database_validate) ? {
      false   => $file_require,
      default => [$file_require, Class['puppetdb::server::validate_read_db']],
    }
    # Set the defaults
    Ini_setting {
      path    => $read_database_ini,
      ensure  => present,
      section => 'read-database',
      require => $ini_setting_require,
    }

    if $read_database == 'postgres' {
      $classname = 'org.postgresql.Driver'
      $subprotocol = 'postgresql'

      if !empty($jdbc_ssl_properties) {
        $database_suffix = $jdbc_ssl_properties
      }
      else {
        $database_suffix = ''
      }

      $subname_default = "//${read_database_host}:${read_database_port}/${read_database_name}${database_suffix}"

      if $postgresql_ssl_on and !empty($jdbc_ssl_properties) {
        fail("Variables 'postgresql_ssl_on' and 'jdbc_ssl_properties' can not be used at the same time!")
      }

      if $postgresql_ssl_on {
        $subname = @("EOT"/L)
          ${subname_default}? \
          ssl=true&sslfactory=org.postgresql.ssl.LibPQFactory& \
          sslmode=verify-full&sslrootcert=${ssl_ca_cert_path}& \
          sslkey=${ssl_key_pk8_path}&sslcert=${ssl_cert_path} \
          | EOT
      } else {
        $subname = $subname_default
      }

      ini_setting { 'puppetdb_read_database_username':
        setting => 'username',
        value   => $read_database_username,
      }

      if $read_database_password != undef and $manage_db_password {
        ini_setting { 'puppetdb_read_database_password':
          setting => 'password',
          value   => $read_database_password,
        }
      }
    }

    ini_setting { 'puppetdb_read_classname':
      setting => 'classname',
      value   => $classname,
    }

    ini_setting { 'puppetdb_read_subprotocol':
      setting => 'subprotocol',
      value   => $subprotocol,
    }

    ini_setting { 'puppetdb_read_pgs':
      setting => 'syntax_pgs',
      value   => true,
    }

    ini_setting { 'puppetdb_read_subname':
      setting => 'subname',
      value   => $subname,
    }

    ini_setting { 'puppetdb_read_log_slow_statements':
      setting => 'log-slow-statements',
      value   => $log_slow_statements,
    }

    ini_setting { 'puppetdb_read_conn_max_age':
      setting => 'conn-max-age',
      value   => $conn_max_age,
    }

    ini_setting { 'puppetdb_read_conn_keep_alive':
      setting => 'conn-keep-alive',
      value   => $conn_keep_alive,
    }

    ini_setting { 'puppetdb_read_conn_lifetime':
      setting => 'conn-lifetime',
      value   => $conn_lifetime,
    }

    if $puppetdb::params::database_max_pool_size_setting_name != undef {
      if $database_max_pool_size == 'absent' {
        ini_setting { 'puppetdb_read_database_max_pool_size':
          ensure  => absent,
          setting => $puppetdb::params::database_max_pool_size_setting_name,
        }
      } elsif $database_max_pool_size != undef {
        ini_setting { 'puppetdb_read_database_max_pool_size':
          setting => $puppetdb::params::database_max_pool_size_setting_name,
          value   => $database_max_pool_size,
        }
      }
    } else {
      file { "${confdir}/read_database.ini":
        ensure => absent,
      }
    }
  } else {
    file { "${confdir}/read_database.ini":
      ensure => absent,
    }
  }
}
