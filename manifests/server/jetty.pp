# @summary PRIVATE CLASS - do not use directly
#
# @api private
#
class puppetdb::server::jetty (
  Optional[String]                     $cipher_suites       = $puppetdb::cipher_suites,
  Stdlib::Absolutepath                 $confdir             = $puppetdb::confdir,
  Boolean                              $disable_cleartext   = $puppetdb::disable_cleartext,
  Boolean                              $disable_ssl         = $puppetdb::disable_ssl,
  Stdlib::Host                         $listen_address      = $puppetdb::listen_address,
  Stdlib::Port                         $listen_port         = $puppetdb::listen_port,
  Optional[String]                     $max_threads         = $puppetdb::max_threads,
  String                               $puppetdb_group      = $puppetdb::puppetdb_group,
  String                               $puppetdb_user       = $puppetdb::puppetdb_user,
  Stdlib::Absolutepath                 $ssl_ca_cert_path    = $puppetdb::ssl_ca_cert_path,
  Stdlib::Absolutepath                 $ssl_cert_path       = $puppetdb::ssl_cert_path,
  Stdlib::Absolutepath                 $ssl_key_path        = $puppetdb::ssl_key_path,
  Stdlib::IP::Address                  $ssl_listen_address  = $puppetdb::ssl_listen_address,
  Stdlib::Port                         $ssl_listen_port     = $puppetdb::ssl_listen_port,
  Optional[Enum['TLSv1.2','TLSv1.3']]  $ssl_protocols       = $puppetdb::ssl_protocols,
  Boolean                              $ssl_set_cert_paths  = $puppetdb::ssl_set_cert_paths,
) {
  # Debug params
  $debug_jetty = @("EOC"/)
    \n
      Puppetdb::Server::Jetty params

                                    cipher_suites: ${cipher_suites}
                                          confdir: ${confdir}
                                disable_cleartext: ${disable_cleartext}
                                      disable_ssl: ${disable_ssl}
                                   listen_address: ${listen_address}
                                      listen_port: ${listen_port}
                                      max_threads: ${max_threads}
                                   puppetdb_group: ${puppetdb_group}
                                    puppetdb_user: ${puppetdb_user}
                                 ssl_ca_cert_path: ${ssl_ca_cert_path}
                                    ssl_cert_path: ${ssl_cert_path}
                                     ssl_key_path: ${ssl_key_path}
                               ssl_listen_address: ${ssl_listen_address}
                                  ssl_listen_port: ${ssl_listen_port}
                                    ssl_protocols: ${ssl_protocols}
                               ssl_set_cert_paths: ${ssl_set_cert_paths}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  #notify { "DEBUG_server_jetty: ${debug_jetty}": }

  $jetty_ini = "${confdir}/jetty.ini"

  file { $jetty_ini:
    ensure => file,
    owner  => $puppetdb_user,
    group  => $puppetdb_group,
    mode   => '0600',
  }

  # Set the defaults
  Ini_setting {
    path    => $jetty_ini,
    ensure  => present,
    section => 'jetty',
    require => File[$jetty_ini],
  }

  $cleartext_setting_ensure = $disable_cleartext ? {
    true    => 'absent',
    default => 'present',
  }

  ini_setting { 'puppetdb_host':
    ensure  => $cleartext_setting_ensure,
    setting => 'host',
    value   => $listen_address,
  }

  ini_setting { 'puppetdb_port':
    ensure  => $cleartext_setting_ensure,
    setting => 'port',
    value   => $listen_port,
  }

  $ssl_setting_ensure = $disable_ssl ? {
    true    => 'absent',
    default => 'present',
  }

  ini_setting { 'puppetdb_sslhost':
    ensure  => $ssl_setting_ensure,
    setting => 'ssl-host',
    value   => $ssl_listen_address,
  }

  ini_setting { 'puppetdb_sslport':
    ensure  => $ssl_setting_ensure,
    setting => 'ssl-port',
    value   => $ssl_listen_port,
  }

  if $ssl_protocols {
    ini_setting { 'puppetdb_sslprotocols':
      ensure  => $ssl_setting_ensure,
      setting => 'ssl-protocols',
      value   => $ssl_protocols,
    }
  }

  if $cipher_suites {
    ini_setting { 'puppetdb_cipher-suites':
      ensure  => $ssl_setting_ensure,
      setting => 'cipher-suites',
      value   => $cipher_suites,
    }
  }

  if $ssl_set_cert_paths {
    # assume paths have been validated in calling class
    ini_setting { 'puppetdb_ssl_key':
      ensure  => present,
      setting => 'ssl-key',
      value   => $ssl_key_path,
    }
    ini_setting { 'puppetdb_ssl_cert':
      ensure  => present,
      setting => 'ssl-cert',
      value   => $ssl_cert_path,
    }
    ini_setting { 'puppetdb_ssl_ca_cert':
      ensure  => present,
      setting => 'ssl-ca-cert',
      value   => $ssl_ca_cert_path,
    }
  }

  if ($max_threads) {
    ini_setting { 'puppetdb_max_threads':
      setting => 'max-threads',
      value   => $max_threads,
    }
  } else {
    ini_setting { 'puppetdb_max_threads':
      ensure  => absent,
      setting => 'max-threads',
    }
  }
}
