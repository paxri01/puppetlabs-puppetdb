# @summary Class to configure a PuppetDB server. See README.md for more details.
#
class puppetdb::server {
  $automatic_dlo_cleanup              = $puppetdb::automatic_dlo_cleanup
  $certificate_whitelist              = $puppetdb::certificate_whitelist
  $certificate_whitelist_file         = $puppetdb::certificate_whitelist_file
  $cipher_suites                      = $puppetdb::cipher_suites
  $cleanup_timer_interval             = $puppetdb::cleanup_timer_interval
  $command_threads                    = $puppetdb::command_threads
  $concurrent_writes                  = $puppetdb::concurrent_writes
  $confdir                            = $puppetdb::confdir
  $conn_keep_alive                    = $puppetdb::conn_keep_alive
  $conn_lifetime                      = $puppetdb::conn_lifetime
  $conn_max_age                       = $puppetdb::conn_max_age
  $database                           = $puppetdb::database
  $database_embedded_path             = $puppetdb::database_embedded_path
  $database_host                      = $puppetdb::database_host
  $database_max_pool_size             = $puppetdb::database_max_pool_size
  $database_name                      = $puppetdb::database_name
  $database_password                  = $puppetdb::database_password
  $database_port                      = $puppetdb::database_port
  $database_username                  = $puppetdb::database_username
  $database_validate                  = $puppetdb::database_validate
  $disable_cleartext                  = $puppetdb::disable_cleartext
  $disable_ssl                        = $puppetdb::disable_ssl
  $disable_update_checking            = $puppetdb::disable_update_checking
  $dlo_max_age                        = $puppetdb::dlo_max_age
  $facts_blacklist                    = $puppetdb::facts_blacklist
  $gc_interval                        = $puppetdb::gc_interval
  $java_args                          = $puppetdb::java_args
  $java_bin                           = $puppetdb::java_bin
  $jdbc_ssl_properties                = $puppetdb::jdbc_ssl_properties
  $listen_address                     = $puppetdb::listen_address
  $listen_port                        = $puppetdb::listen_port
  $log_slow_statements                = $puppetdb::log_slow_statements
  $manage_database                    = $puppetdb::manage_database
  $manage_db_password                 = $puppetdb::manage_db_password
  $manage_firewall                    = $puppetdb::manage_firewall
  $manage_read_db_password            = $puppetdb::manage_read_db_password
  $max_threads                        = $puppetdb::max_threads
  $merge_default_java_args            = $puppetdb::merge_default_java_args
  $migrate                            = $puppetdb::migrate
  $node_purge_gc_batch_limit          = $puppetdb::node_purge_gc_batch_limit
  $node_purge_ttl                     = $puppetdb::node_purge_ttl
  $node_ttl                           = $puppetdb::node_ttl
  $open_listen_port                   = $puppetdb::open_listen_port
  $open_ssl_listen_port               = $puppetdb::open_ssl_listen_port
  $postgresql_ssl_on                  = $puppetdb::postgresql_ssl_on
  $puppetdb_group                     = $puppetdb::puppetdb_group
  $puppetdb_initconf                  = $puppetdb::puppetdb_initconf
  $puppetdb_package                   = $puppetdb::puppetdb_package
  $puppetdb_service                   = $puppetdb::puppetdb_service
  $puppetdb_service_status            = $puppetdb::puppetdb_service_status
  $puppetdb_user                      = $puppetdb::puppetdb_user
  $read_conn_keep_alive               = $puppetdb::read_conn_keep_alive
  $read_conn_lifetime                 = $puppetdb::read_conn_lifetime
  $read_conn_max_age                  = $puppetdb::read_conn_max_age
  $read_database                      = $puppetdb::read_database
  $read_database_host                 = $puppetdb::read_database_host
  $read_database_jdbc_ssl_properties  = $puppetdb::read_database_jdbc_ssl_properties
  $read_database_max_pool_size        = $puppetdb::read_database_max_pool_size
  $read_database_name                 = $puppetdb::read_database_name
  $read_database_password             = $puppetdb::read_database_password
  $read_database_port                 = $puppetdb::read_database_port
  $read_database_username             = $puppetdb::read_database_username
  $read_database_validate             = $puppetdb::read_database_validate
  $read_log_slow_statements           = $puppetdb::read_log_slow_statements
  $report_ttl                         = $puppetdb::report_ttl
  $ssl_ca_cert                        = $puppetdb::ssl_ca_cert
  $ssl_ca_cert_path                   = $puppetdb::ssl_ca_cert_path
  $ssl_cert                           = $puppetdb::ssl_cert
  $ssl_cert_path                      = $puppetdb::ssl_cert_path
  $ssl_deploy_certs                   = $puppetdb::ssl_deploy_certs
  $ssl_dir                            = $puppetdb::ssl_dir
  $ssl_key                            = $puppetdb::ssl_key
  $ssl_key_path                       = $puppetdb::ssl_key_path
  $ssl_key_pk8_path                   = $puppetdb::ssl_key_pk8_path
  $ssl_listen_address                 = $puppetdb::ssl_listen_address
  $ssl_listen_port                    = $puppetdb::ssl_listen_port
  $ssl_protocols                      = $puppetdb::ssl_protocols
  $ssl_set_cert_paths                 = $puppetdb::ssl_set_cert_paths
  $store_usage                        = $puppetdb::store_usage
  $temp_usage                         = $puppetdb::temp_usage
  $vardir                             = $puppetdb::vardir

  # Apply necessary suffix if zero is specified.
  # Can we drop this in the next major release?
  if $node_ttl == '0' {
    $_node_ttl_real = '0s'
  } else {
    $_node_ttl_real = downcase($node_ttl)
  }

  # Validate node_ttl
  $node_ttl_real = assert_type(Puppetdb::Ttl, $_node_ttl_real)

  # Apply necessary suffix if zero is specified.
  # Can we drop this in the next major release?
  if $node_purge_ttl == '0' {
    $_node_purge_ttl_real = '0s'
  } else {
    $_node_purge_ttl_real = downcase($node_purge_ttl)
  }

  # Validate node_purge_ttl
  $node_purge_ttl_real = assert_type(Puppetdb::Ttl, $_node_purge_ttl_real)

  # Apply necessary suffix if zero is specified.
  # Can we drop this in the next major release?
  if $report_ttl == '0' {
    $_report_ttl_real = '0s'
  } else {
    $_report_ttl_real = downcase($report_ttl)
  }

  # Validate report_ttl
  $repor_ttl_real = assert_type(Puppetdb::Ttl, $_report_ttl_real)

  # Validate puppetdb_service_status
  $service_enabled = $puppetdb_service_status ? {
    /(running|true)/  => true,
    /(stopped|false)/ => false,
    default           => fail("Invalid service status: '${puppetdb_service_status}'"),
  }

  # Validate database type (Currently only postgres and embedded are supported)
  if !($database in ['postgres', 'embedded']) {
    fail("database must must be 'postgres' or 'embedded'. You provided '${database}'")
  }

  # Validate read-database type (Currently only postgres is supported)
  if !($read_database in ['postgres']) {
    fail("read_database must be 'postgres'. You provided '${read_database}'")
  }

  ensure_packages([$puppetdb_package],
    {
      ensure => $puppetdb::puppetdb_version,
      notify => Service[$puppetdb_service],
    }
  )

  if $manage_firewall == true {
    class { 'puppetdb::server::firewall': }
  }

  class { 'puppetdb::server::global': notify => Service[$puppetdb_service] }
  class { 'puppetdb::server::command_processing': notify => Service[$puppetdb_service] }
  class { 'puppetdb::server::database': notify => Service[$puppetdb_service] }

  if $manage_database == true and $read_database_host == undef {
    $real_database_host = $database_host
    $real_database_port = $database_port
    $real_database_name = $database_name
  } else {
    $real_database_host =  $read_database_host
    $real_database_port =  $read_database_port
    $real_database_name =  $read_database_name
  }

  class { 'puppetdb::server::read_database': notify => Service[$puppetdb_service] }

  if $ssl_deploy_certs {
    file {
      $ssl_dir:
        ensure => directory,
        owner  => $puppetdb_user,
        group  => $puppetdb_group,
        mode   => '0700';
      $ssl_key_path:
        ensure  => file,
        content => $ssl_key,
        owner   => $puppetdb_user,
        group   => $puppetdb_group,
        mode    => '0600',
        notify  => Service[$puppetdb_service];
      $ssl_cert_path:
        ensure  => file,
        content => $ssl_cert,
        owner   => $puppetdb_user,
        group   => $puppetdb_group,
        mode    => '0600',
        notify  => Service[$puppetdb_service];
      $ssl_ca_cert_path:
        ensure  => file,
        content => $ssl_ca_cert,
        owner   => $puppetdb_user,
        group   => $puppetdb_group,
        mode    => '0600',
        notify  => Service[$puppetdb_service];
    }
  }

  if $postgresql_ssl_on {
    exec { $ssl_key_pk8_path:
      path    => ['/opt/puppetlabs/puppet/bin', $facts['path']],
      command => "openssl pkcs8 -topk8 -inform PEM -outform DER -in ${ssl_key_path} -out ${ssl_key_pk8_path} -nocrypt",
      # Generate a .pk8 key if one doesn't exist or is older than the .pem input.
      # NOTE: bash file time checks, like -ot, can't always discern sub-second
      # differences.
      onlyif  => "test ! -e '${ssl_key_pk8_path}' -o '${ssl_key_pk8_path}' -ot '${ssl_key_path}'",
      before  => File[$ssl_key_pk8_path],
    }

    file { $ssl_key_pk8_path:
      ensure => 'file',
      owner  => $puppetdb_user,
      group  => $puppetdb_group,
      mode   => '0600',
      notify => Service[$puppetdb_service],
    }
  }

  class { 'puppetdb::server::jetty': notify => Service[$puppetdb_service] }
  class { 'puppetdb::server::puppetdb': notify => Service[$puppetdb_service] }

  if !empty($java_args) {
    if $merge_default_java_args {
      create_resources(
        'ini_subsetting',
        puppetdb::create_subsetting_resource_hash(
          $java_args, {
            ensure            => present,
            section           => '',
            key_val_separator => '=',
            path              => $puppetdb_initconf,
            setting           => 'JAVA_ARGS',
            require           => Package[$puppetdb_package],
            notify            => Service[$puppetdb_service],
          }
        )
      )
    } else {
      ini_setting { 'java_args':
        ensure  => present,
        section => '',
        path    => $puppetdb_initconf,
        setting => 'JAVA_ARGS',
        require => Package[$puppetdb_package],
        notify  => Service[$puppetdb_service],
        value   => puppetdb::flatten_java_args($java_args),
      }
    }
  }

  # java binary path for PuppetDB. If undef, default will be used.
  if $java_bin {
    ini_setting { 'java':
      ensure  => 'present',
      section => '',
      path    => $puppetdb_initconf,
      setting => 'JAVA_BIN',
      require => Package[$puppetdb_package],
      notify  => Service[$puppetdb_service],
      value   => $java_bin,
    }
  }

  if $automatic_dlo_cleanup {
    if $facts['systemd'] {
      # deploy a systemd timer + service to cleanup old reports
      # https://puppet.com/docs/puppetdb/5.2/maintain_and_tune.html#clean-up-the-dead-letter-office
      systemd::unit_file { 'puppetdb-dlo-cleanup.service':
        content => epp("${module_name}/puppetdb-DLO-cleanup.service.epp",
          {
            'puppetdb_user'  => $puppetdb_user,
            'puppetdb_group' => $puppetdb_group,
            'vardir'         => $vardir,
            'dlo_max_age'    => $dlo_max_age
          }
        ),
      }
      -> systemd::unit_file { 'puppetdb-dlo-cleanup.timer':
        content => epp("${module_name}/puppetdb-DLO-cleanup.timer.epp",
          { 'cleanup_timer_interval' => $cleanup_timer_interval }
        ),
        enable  => true,
        active  => true,
      }
    } else {
      cron { 'puppetdb-dlo-cleanup':
        ensure   => 'present',
        minute   => fqdn_rand(60),
        hour     => fqdn_rand(24),
        monthday => '*',
        month    => '*',
        weekday  => '*',
        command  => "/usr/bin/find ${vardir}/stockpile/discard/ -type f -mtime ${dlo_max_age} -delete",
        user     => $puppetdb_user,
      }
    }
  }

  service { $puppetdb_service:
    ensure => $puppetdb_service_status,
    enable => $service_enabled,
  }

  if $manage_firewall {
    Package[$puppetdb_package]
    -> Class['puppetdb::server::firewall']
    -> Class['puppetdb::server::global']
    -> Class['puppetdb::server::command_processing']
    -> Class['puppetdb::server::database']
    -> Class['puppetdb::server::read_database']
    -> Class['puppetdb::server::jetty']
    -> Class['puppetdb::server::puppetdb']
    -> Service[$puppetdb_service]
  } else {
    Package[$puppetdb_package]
    -> Class['puppetdb::server::global']
    -> Class['puppetdb::server::command_processing']
    -> Class['puppetdb::server::database']
    -> Class['puppetdb::server::read_database']
    -> Class['puppetdb::server::jetty']
    -> Class['puppetdb::server::puppetdb']
    -> Service[$puppetdb_service]
  }
}
