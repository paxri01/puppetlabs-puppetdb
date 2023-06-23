# @summary Class to configure a PuppetDB server. See README.md for more details.
#
# @param automatic_dlo_cleanup
# @param cleanup_timer_interval
# @param database
# @param database_host
# @param database_name
# @param database_port
# @param dlo_max_age
# @param java_args
# @param java_bin
# @param manage_database
# @param manage_firewall
# @param merge_default_java_args
# @param node_purge_ttl
# @param node_ttl
# @param postgresql_ssl_on
# @param puppetdb_group
# @param puppetdb_initconf
# @param puppetdb_package
# @param puppetdb_service
# @param puppetdb_service_status
# @param puppetdb_user
# @param read_database
# @param read_database_host
# @param read_database_name
# @param read_database_port
# @param report_ttl
# @param ssl_ca_cert
# @param ssl_ca_cert_path
# @param ssl_cert
# @param ssl_cert_path
# @param ssl_deploy_certs
# @param ssl_dir
# @param ssl_key
# @param ssl_key_path
# @param ssl_key_pk8_path
# @param vardir
#
class puppetdb::server (
  Boolean                        $automatic_dlo_cleanup      = $puppetdb::automatic_dlo_cleanup,
  String                         $cleanup_timer_interval     = $puppetdb::cleanup_timer_interval,
  String                         $database                   = $puppetdb::database,
  Stdlib::Host                   $database_host              = $puppetdb::database_host,
  String                         $database_name              = $puppetdb::database_name,
  Stdlib::Port                   $database_port              = $puppetdb::database_port,
  Integer                        $dlo_max_age                = $puppetdb::dlo_max_age,
  Optional[String]               $java_args                  = $puppetdb::java_args,
  Optional[Stdlib::Absolutepath] $java_bin                   = $puppetdb::java_bin,
  Boolean                        $manage_database            = $puppetdb::manage_database,
  Boolean                        $manage_firewall            = $puppetdb::manage_firewall,
  Boolean                        $merge_default_java_args    = $puppetdb::merge_default_java_args,
  String                         $node_purge_ttl             = $puppetdb::node_purge_ttl,
  String                         $node_ttl                   = $puppetdb::node_ttl,
  Boolean                        $postgresql_ssl_on          = $puppetdb::postgresql_ssl_on,
  String                         $puppetdb_group             = $puppetdb::puppetdb_group,
  Stdlib::Absolutepath           $puppetdb_initconf          = $puppetdb::puppetdb_initconf,
  String                         $puppetdb_package           = $puppetdb::puppetdb_package,
  String                         $puppetdb_service           = $puppetdb::puppetdb_service,
  String                         $puppetdb_service_status    = $puppetdb::puppetdb_service_status,
  String                         $puppetdb_user              = $puppetdb::puppetdb_user,
  Stdlib::Host                   $read_database_host         = $puppetdb::read_database_host,
  String                         $read_database_name         = $puppetdb::read_database_name,
  Stdlib::Port                   $read_database_port         = $puppetdb::read_database_port,
  String                         $read_database              = $puppetdb::read_database,
  String                         $report_ttl                 = $puppetdb::report_ttl,
  Stdlib::Absolutepath           $ssl_ca_cert_path           = $puppetdb::ssl_ca_cert_path,
  Optional[String]               $ssl_ca_cert                = $puppetdb::ssl_ca_cert,
  Stdlib::Absolutepath           $ssl_cert_path              = $puppetdb::ssl_cert_path,
  Optional[String]               $ssl_cert                   = $puppetdb::ssl_cert,
  Boolean                        $ssl_deploy_certs           = $puppetdb::ssl_deploy_certs,
  Stdlib::Absolutepath           $ssl_dir                    = $puppetdb::ssl_dir,
  Stdlib::Absolutepath           $ssl_key_path               = $puppetdb::ssl_key_path,
  Stdlib::Absolutepath           $ssl_key_pk8_path           = $puppetdb::ssl_key_pk8_path,
  Optional[String]               $ssl_key                    = $puppetdb::ssl_key,
  Stdlib::Absolutepath           $vardir                     = $puppetdb::vardir,
) {
  # Debug params
  $debug_server = @("EOC"/)
    \n
      Puppetdb::Server params

                            automatic_dlo_cleanup: ${automatic_dlo_cleanup}
                           cleanup_timer_interval: ${cleanup_timer_interval}
                                         database: ${database}
                                    database_host: ${database_host}
                                    database_name: ${database_name}
                                    database_port: ${database_port}
                                      dlo_max_age: ${dlo_max_age}
                                        java_args: ${java_args}
                                         java_bin: ${java_bin}
                                  manage_database: ${manage_database}
                                  manage_firewall: ${manage_firewall}
                          merge_default_java_args: ${merge_default_java_args}
                                   node_purge_ttl: ${node_purge_ttl}
                                         node_ttl: ${node_ttl}
                                postgresql_ssl_on: ${postgresql_ssl_on}
                                   puppetdb_group: ${puppetdb_group}
                                puppetdb_initconf: ${puppetdb_initconf}
                                 puppetdb_package: ${puppetdb_package}
                                 puppetdb_service: ${puppetdb_service}
                          puppetdb_service_status: ${puppetdb_service_status}
                                    puppetdb_user: ${puppetdb_user}
                               read_database_host: ${read_database_host}
                               read_database_name: ${read_database_name}
                               read_database_port: ${read_database_port}
                                    read_database: ${read_database}
                                       report_ttl: ${report_ttl}
                                 ssl_ca_cert_path: ${ssl_ca_cert_path}
                                      ssl_ca_cert: ${ssl_ca_cert}
                                    ssl_cert_path: ${ssl_cert_path}
                                         ssl_cert: ${ssl_cert}
                                 ssl_deploy_certs: ${ssl_deploy_certs}
                                          ssl_dir: ${ssl_dir}
                                     ssl_key_path: ${ssl_key_path}
                                 ssl_key_pk8_path: ${ssl_key_pk8_path}
                                          ssl_key: ${ssl_key}
                                           vardir: ${vardir}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  #notify { "DEBUG_server_firewall: ${debug_server}": }

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
