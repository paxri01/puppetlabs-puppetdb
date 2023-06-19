# @summary All in one class for setting up a PuppetDB instance. See README.md for more details.
#
# @param automatic_dlo_cleanup
#   PuppetDB creates [Dead Letter Office]
#   https://puppet.com/docs/puppetdb/5.2/maintain_and_tune.html#clean-up-the-dead-letter-office.
#   Those are reports of failed requests. They spill up the disk. This parameter is a boolean
#   and defaults to false. You can enable automatic cleanup of DLO reports by setting this to true.
# @param certificate_whitelist
#   Array of the X.509 certificate Common Names of clients allowed to connect to PuppetDB.
#   Defaults to empty. Be aware that this permits full access to all Puppet clients to download
#   anything contained in PuppetDB, including the full catalogs of all nodes, which possibly
#   contain sensitive information. Set to '[ $::servername ]' to allow access only from your
#   (single) Puppet master, which is enough for normal operation. Set to a list of Puppet
#   masters if you have multiple.
# @param certificate_whitelist_file
#   The name of the certificate whitelist file to set up and configure in PuppetDB. Defaults
#   to '/etc/puppetdb/certificate-whitelist' or '/etc/puppetlabs/puppetdb/certificate-whitelist'
#   for FOSS and PE respectively.
# @param cipher_suites
#   Configure jetty's supported 'cipher-suites' (e.g. 'SSL_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384').
#   Defaults to 'undef'.
# @param cleanup_timer_interval
#   The DLO cleanup is a systemd timer if systemd is available, otherwise a cronjob. The variable
#   configures the systemd.timer option [onCalender]
#   https://www.freedesktop.org/software/systemd/man/systemd.timer.html#OnCalendar=.
#   It defaults to '*-*-* ${fqdn_rand(24)}:${fqdn_rand(60)}:00'. This will start the cleanup
#   service on a daily basis. The exact minute and hour is random per node based on the
#   [fqdn_rand](https://puppet.com/docs/puppet/5.5/function.html#fqdnrand) method. On
#   non-systemd systems, the cron runs daily and the '$puppetdb_user' needs to be able to run
#   cron jobs. On systemd systems you need the [camptocamp/systemd]
#   (https://forge.puppet.com/camptocamp/systemd) module, which is an optional dependency
#   and not automatically installed!
# @param command_threads
#   The number of command processing threads to use. Defaults to 'undef', using the PuppetDB
#   built-in default.
# @param concurrent_writes
#   The number of threads allowed to write to disk at any one time. Defaults to 'undef',
#   which uses the PuppetDB built-in default.
# @param confdir
#   The PuppetDB configuration directory. Defaults to '/etc/puppetdb/conf.d'.
# @param conn_keep_alive
#   This sets the time (in minutes) for a connection to remain idle before sending a test
#   query to the DB. This is useful to prevent a DB from timing out connections on its end.
#
#   If not supplied, we default to 45 minutes. This option is supported in PuppetDB >= 1.1.
# @param conn_lifetime
#   The maximum time (in minutes) a pooled connection should remain open. Any connections
#   older than this setting will be closed off. Connections currently in use will not be
#   affected until they are returned to the pool.
#
#   If not supplied, we won't terminate connections based on their age alone. This option
#   is supported in PuppetDB >= 1.4.
# @param conn_max_age
#   The maximum time (in minutes) for a pooled connection to remain unused before it is
#   closed off.
#
#   If not supplied, we default to '60' minutes. This option is supported in PuppetDB >= 1.1.
# @param create_puppet_service_resource
#   If 'true', AND if 'restart_puppet' is true, then the module will create a service resource
#   for 'puppet_service_name' if it has not been defined. Defaults to 'true'.  If you are
#   already declaring the 'puppet_service_name' service resource in another part of your code,
#   setting this to 'false' will avoid creation of that service resource by this module,
#   avoiding potential duplicate resource errors.
# @param database
#   Which database backend to use; legal values are 'postgres' (default) or 'embedded'.
#   The 'embedded' option is not supported on PuppetDB 4.0.0 or later. 'embedded' can be used
#   for very small installations or for testing, but is not recommended for use in production
#   environments.
# @see https://puppet.com/docs/puppetdb/latest/
# @param database_embedded_path
#   *Embedded Database Only* Changes the path location for the HSQLDB database. Does not
#   provide migration for old data, so if you change this value and you have an existing
#   database you will need to manually move the content also. (defaults to package default
#   for 2.x release).
# @param database_host
#   Hostname to use for the database connection. For single case installations this should be
#   left as the default. Defaults to 'localhost', ignored for 'embedded' database.
# @param database_listen_address
#   TODO
# @param database_max_pool_size
#   TODO
# @param database_name
#   The name of the database instance to connect to. Defaults to 'puppetdb', ignored
#   for 'embedded' database.
# @param database_password
#   The password for the database user. Defaults to 'puppetdb', ignored for 'embedded' database.
# @param database_port
#   The port that the database server listens on. Defaults to '5432', ignored for
#   'embedded' database.
# @param database_username
#   The name of the database user to connect as. Defaults to 'puppetdb', ignored for
#   'embedded' database.
# @param database_validate
#   If true, the module will attempt to connect to the database using the specified
#   settings and fail if it is not able to do so. Defaults to 'true'.
# @param disable_cleartext
#   If true, the puppetdb web server will only serve HTTPS and not HTTP requests (defaults to false).
# @param disable_ssl
#   If 'true', the puppetdb web server will only serve HTTP and not HTTPS requests.
#   Defaults to 'false'.
# @param disable_update_checking
#   Setting this to true disables checking for updated versions of PuppetDB and sending basic
#   analytics data to Puppet.  Defaults to 'undef', using the PuppetDB built-in default.
# @param dlo_max_age
#   This is a positive integer. It describes the amount of days you want to keep the DLO reports.
#   The default value is 90 days.
# @param enable_reports
#   Ignored unless 'manage_report_processor' is 'true', in which case this setting will
#   determine whether or not the PuppetDB report processor is enabled ('true') or disabled
#   ('false') in the puppet.conf file.
# @param enable_storeconfigs
#   Ignored unless 'manage_storeconfigs' is 'true', in which case this setting will determine
#   whether or not client configuration storage is enabled ('true') or disabled ('false') in
#   the puppet.conf file.
# @param facts_blacklist
#   TODO
# @param gc_interval
#   This controls how often (in minutes) to compact the database. The compaction process
#   reclaims space and deletes unnecessary rows. If not supplied, the default is every
#   60 minutes. This option is supported in PuppetDB >= 0.9.
# @param java_args
#   Java VM options used for overriding default Java VM options specified in PuppetDB
#   package. Defaults to '{}'.
# @see https://puppet.com/docs/puppetdb/latest/configure.html
# @example
#   To set '-Xmx512m -Xms256m' options use:
#    {
#        '-Xmx' => '512m',
#        '-Xms' => '256m',
#    }
# @param java_bin
#   TODO
# @param jdbc_ssl_properties
#   The text to append to the JDBC connection URI. This should begin with a '?' character.
#   For example, to use SSL for the PostgreSQL connection, set this parameter's value to
#   '?ssl=true'.
#
#   This setting is only available when using PostgreSQL; when using HyperSQL
#   (the 'embedded' database), it does nothing.
# @param listen_address
#   The address that the web server should bind to for HTTP requests. Defaults to
#   'localhost'. Set to '0.0.0.0' to listen on all addresses.
# @param listen_port
#   The port on which the puppetdb web server should accept HTTP requests. Defaults to '8080'.
# @param log_slow_statements
#   This sets the number of seconds before an SQL query is considered "slow." Slow SQL
#   queries are logged as warnings, to assist in debugging and tuning.
#   Note PuppetDB does not interrupt slow queries; it simply reports them after they complete.
#
#   The default value is '10' seconds. A value of 0 will disable logging of slow queries.
#   This option is supported in PuppetDB >= 1.1.
# @param manage_config
#   If 'true', the module will store values from 'puppetdb_server' and 'puppetdb_port' parameters
#   in the PuppetDB configuration file. If 'false', an existing PuppetDB configuration file
#   will be used to retrieve server and port values.
# @param manage_database
#   If true, the PostgreSQL database will be managed by this module. Defaults to 'true'.
# @param manage_db_password
#   Whether or not the database password in database.ini will be managed by this module.
#   Set this to 'false' if you want to set the password some other way.  Defaults to 'true'
# @param manage_dbserver
#   If true, the PostgreSQL server will be managed by this module. Defaults to 'true'.
# @param manage_dnf_module
#   If 'true', enable specified postgresql version appstream for EL 8 systems. Also override
#   $server_package_name within postgresql module.  Defaults to false.
# @param manage_firewall
#   If 'true', puppet will manage your iptables rules for PuppetDB via the [puppetlabs-firewall]
#   (https://forge.puppetlabs.com/puppetlabs/firewall) class.
# @param manage_package_repo
#   If 'true', the official postgresql.org repo will be added and postgres won't be installed
#   from the regular repository. Defaults to 'true'.
# @param manage_read_db_password
#   Whether or not the database password in read-database.ini will be managed by this module.
#   Set this to 'false' if you want to set the password some other way. Defaults to 'true'
# @param manage_report_processor
#   If 'true', the module will manage the 'reports' field in the puppet.conf file to enable
#   or disable the PuppetDB report processor. Defaults to 'false'.
# @param manage_routes
#   If 'true', the module will overwrite the Puppet master's routes file to configure it to
#   use PuppetDB. Defaults to 'true'.
# @param manage_server
#   Conditionally manages the PostgreSQL server via 'postgresql::server'. Defaults to 'true'.
#   If set to 'false', this class will create the database and user via 'postgresql::server::db'
#   but not attempt to install or manage the server itself.
# @param manage_storeconfigs
#   If 'true', the module will manage the Puppet master's storeconfig settings.  Defaults
#   to 'true'.
# @param masterless
#   A boolean switch to enable or disable the masterless setup of PuppetDB. Defaults to 'false'.
# @param max_threads
#   Jetty option to explicitly set 'max-threads'. Defaults to 'undef', so the PuppetDB-Jetty
#   default is used.
# @param merge_default_java_args
#   Sets whether the provided java args should be merged with the defaults, or should
#   override the defaults. This setting is necessary if any of the defaults are to be
#   removed. Defaults to true. If 'false', the 'java_args' in the PuppetDB init config
#   file will reflect only what is passed via the 'java_args' param.
# @param migrate
#   If 'true', puppetdb will automatically migrate to the latest database format at startup.
#   If 'false', if the database format supplied by this version of PuppetDB doesn't match the
#   version expected (whether newer or older), PuppetDB will exit with an error status.
#   Defaults to 'true'.
# @param node_purge_gc_batch_limit
#   TODO
# @param node_purge_ttl
#   The length of time a node can be deactivated before it's deleted from the database.
#   (defaults to '14d', which is a 14-day period. Set to '0d' to disable purging). This
#   option is supported in PuppetDB >= 1.2.0.
# @param node_ttl
#   The length of time a node can go without receiving any new data before it's automatically
#   deactivated. (defaults to '7d', which is a 7-day period. Set to '0d' to disable
#   auto-deactivation).  This option is supported in PuppetDB >= 1.1.0.
# @param open_listen_port
#   If 'true', open the 'http_listen_port' on the firewall. Defaults to 'false'.
# @param open_ssl_listen_port
#   If true, open the 'ssl_listen_port' on the firewall. Defaults to 'undef'.
# @param postgresql_ssl_on
#   If 'true', it configures SSL connections between PuppetDB and the PostgreSQL database.
#   Defaults to 'false'.
# @param postgres_version
#   If the postgresql.org repo is installed, you can install several versions of postgres.
#   Defaults to '9.6' in module version 6.0+ and '9.4' in older versions.
# @param postgresql_ssl_ca_cert_path
# @param postgresql_ssl_cert_path
# @param postgresql_ssl_folder
# @param postgresql_ssl_key_path
# @param puppet_conf
#   Puppet's config file. Defaults to '/etc/puppet/puppet.conf'.
# @param puppet_confdir
#   Puppet's config directory. Defaults to '/etc/puppet'.
# @param puppet_service_name
#   Name of the service that represents Puppet. You can change this to 'apache2' or 'httpd'
#   depending on your operating system, if you plan on having Puppet run using Apache/Passenger
#   for example.
# @param puppetdb_disable_ssl
#   If true, use plain HTTP to talk to PuppetDB. Defaults to the value of 'disable_ssl' if
#   PuppetDB is on the same server as the Puppet Master, or else false. If you set this, you
#   probably need to set 'puppetdb_port' to match the HTTP port of the PuppetDB.
# @param puppetdb_group
#   TODO
# @param puppetdb_initconf
#   TODO
# @param puppetdb_package
#   The PuppetDB package name in the package manager. Defaults to 'puppetdb'.
# @param puppetdb_port
#   The port that the PuppetDB server is running on. Defaults to '8081'.
# @param puppetdb_server
#   The dns name or ip of the PuppetDB server. Defaults to the hostname of the current node,
#   i.e. '$::fqdn'.
# @param puppetdb_service
#   The name of the PuppetDB service. Defaults to 'puppetdb'.
# @param puppetdb_service_status
#   Sets whether the service should be 'running ' or 'stopped'. When set to 'stopped' the
#   service doesn't start on boot either. Valid values are 'true', 'running', 'false',
#   and 'stopped'.
# @param puppetdb_soft_write_failure
#   Boolean to fail in a soft manner if PuppetDB is not accessible for command submission
#   Defaults to 'false'.
# @param puppetdb_startup_timeout
#   The maximum amount of time that the module should wait for PuppetDB to start up.  This is
#   most important during the initial install of PuppetDB (defaults to 15 seconds).
# @param puppetdb_user
#   TODO
# @param puppetdb_version
#   TODO
# @param read_conn_keep_alive
#   This sets the time (in minutes) for a read database connection to remain idle before
#   sending a test query to the DB. This is useful to prevent a DB from timing out
#   connections on its end.
#
#   If not supplied, we default to 45 minutes. This option is supported in PuppetDB >= 1.6.
# @param read_conn_lifetime
#   The maximum time (in minutes) a pooled read database connection should remain open.
#   Any connections older than this setting will be closed off. Connections currently in use
#   will not be affected until they are returned to the pool.
#
#   If not supplied, we won't terminate connections based on their age alone. This option is
#   supported in PuppetDB >= 1.6.
# @param read_conn_max_age
#   The maximum time (in minutes) for a pooled read database connection to remain unused
#   before it is closed off.
#
#   If not supplied, we default to 60 minutes. This option is supported in PuppetDB >= 1.6.
# @param read_database
#   Which database backend to use for the read database. Only supports 'postgres'
#   (default). This option is supported in PuppetDB >= 1.6.
# @param read_database_host
#   *This parameter must be set to use another PuppetDB instance for queries.*
#
#   The hostname or IP address of the read database server. If set to 'undef', and
#   'manage_database' is set to 'true', it will use the value of the 'database_host'
#   parameter. This option is supported in PuppetDB >= 1.6.
# @param read_database_name
#   The name of the read database instance to connect to. If 'read_database_host' is set
#   to 'undef', and 'manage_database' is set to 'true', it will use the value of the
#   'database_name' parameter. This option is supported in PuppetDB >= 1.6.
# @param read_database_password
#   The password for the read database user. Defaults to 'puppetdb-read'. This option is
#   supported in PuppetDB >= 1.6.
# @param read_database_jdbc_ssl_properties
#   TODO
# @param read_database_max_pool_size
#   TODO
# @param read_database_port
#   The port that the read database server listens on. If 'read_database_host' is set
#   to 'undef', and 'manage_database' is set to 'true', it will use the value of the
#   'database_port' parameter. This option is supported in PuppetDB >= 1.6.
# @param read_database_username
#   The name of the read database user to connect as. Defaults to 'puppetdb-read'.
#   This option is supported in PuppetDB >= 1.6.
# @param read_database_validate
#   TODO
# @param read_log_slow_statements
#   This sets the number of seconds before an SQL query to the read database is considered
#   "slow." Slow SQL queries are logged as warnings, to assist in debugging and tuning.
#   Note PuppetDB does not interrupt slow queries; it simply reports them after they complete.
#
#   The default value is 10 seconds. A value of 0 will disable logging of slow queries.
#   This option is supported in PuppetDB >= 1.6.
# @param report_ttl
#   The length of time reports should be stored before being deleted. (defaults to '14d',
#   which is a 14-day period). This option is supported in PuppetDB >= 1.1.0.
# @param restart_puppet
#   If 'true', the module will restart the Puppet master when PuppetDB configuration files are
#   changed by the module. Defaults to 'true'. If set to 'false', you must restart the service
#   manually in order to pick up changes to the config files (other than 'puppet.conf').
# @param ssl_ca_cert
#   Contents of your SSL CA certificate, as a string.
# @param ssl_ca_cert_path
#   Path to your SSL CA for populating 'jetty.ini'.
# @param ssl_cert
#   Contents of your SSL certificate, as a string.
# @param ssl_cert_path
#   Path to your SSL certificate for populating 'jetty.ini'.
# @param ssl_deploy_certs
#   A boolean switch to enable or disable the management of SSL keys in your 'ssl_dir'.
#   Default is 'false'.
# @param ssl_dir
#   Base directory for PuppetDB SSL configuration. Defaults to '/etc/puppetdb/ssl' or
#   '/etc/puppetlabs/puppetdb/ssl' for FOSS and PE respectively.
# @param ssl_key
#   Contents of your SSL key, as a string.
# @param ssl_key_path
#   Path to your SSL key for populating 'jetty.ini'.
# @param ssl_key_pk8_path
#   TODO
# @param ssl_listen_address
#   The address that the web server should bind to for HTTPS requests.
#   Defaults to '0.0.0.0' to listen on all addresses.
# @param ssl_listen_port
#   The port on which the puppetdb web server should accept HTTPS requests. Defaults to '8081'.
# @param ssl_protocols
#   Specify the supported SSL protocols for PuppetDB (e.g. TLSv1, TLSv1.1, TLSv1.2.)
# @param ssl_set_cert_paths
#   A switch to enable or disable the management of SSL certificates in your 'jetty.ini'
#   configuration file.
# @param store_usage
#   The amount of disk space (in MB) to allow for persistent message storage.  Defaults to
#   'undef', using the PuppetDB built-in default.
# @param strict_validation
#   If 'true', the module will fail if PuppetDB is not reachable, otherwise it will preconfigure
#   PuppetDB without checking.
# @param temp_usage
#   The amount of disk space (in MB) to allow for temporary message storage.  Defaults to
#   'undef', using the PuppetDB built-in default.
# @param terminus_package
#   Name of the package to use that represents the PuppetDB terminus code. Defaults to
#   'puppetdb-termini', when 'puppetdb_version' is set to '<= 2.3.x' the default changes to
#   'puppetdb-terminus'.
# @param test_url
#   The URL to use for testing if the PuppetDB instance is running. Defaults to
#   '/pdb/meta/v1/version'.
# @param vardir
#   The parent directory for the MQ's data directory.
#
class puppetdb (
  Boolean                        $automatic_dlo_cleanup             = true,
  Stdlib::Absolutepath           $certificate_whitelist_file        = $puppetdb::params::certificate_whitelist_file,
  # change to this to only allow access by the puppet master by default:
  #Optional[Array]                $certificate_whitelist        = [ $::servername ]
  Optional[Array]                $certificate_whitelist             = undef,
  Optional[String]               $cipher_suites                     = $puppetdb::params::cipher_suites,
  String                         $cleanup_timer_interval            = "*-*-* ${fqdn_rand(24)}:${fqdn_rand(60)}:00",
  Optional[String]               $command_threads                   = undef,
  Optional[String]               $concurrent_writes                 = undef,
  Stdlib::Absolutepath           $confdir                           = $puppetdb::params::confdir,
  String                         $conn_keep_alive                   = '45',
  String                         $conn_lifetime                     = '0',
  String                         $conn_max_age                      = '60',
  Boolean                        $create_puppet_service_resource    = true,
  Stdlib::Absolutepath           $database_embedded_path            = $puppetdb::params::database_embedded_path,
  Stdlib::Host                   $database_host                     = 'localhost',
  Stdlib::Host                   $database_listen_address           = 'localhost',
  Optional[String]               $database_max_pool_size            = undef,
  String                         $database_name                     = 'puppetdb',
  String                         $database_password                 = 'puppetdb',
  Stdlib::Port                   $database_port                     = 5432,
  String                         $database                          = 'postgres',
  String                         $database_username                 = 'puppetdb',
  Boolean                        $database_validate                 = true,
  Boolean                        $disable_cleartext                 = false,
  Boolean                        $disable_ssl                       = false,
  Optional[String]               $disable_update_checking           = undef,
  Integer                        $dlo_max_age                       = 90,
  Boolean                        $enable_reports                    = false,
  Boolean                        $enable_storeconfigs               = true,
  Optional[Array]                $facts_blacklist                   = undef,
  String                         $gc_interval                       = '60',
  Optional[String]               $java_args                         = undef,
  Optional[Stdlib::Absolutepath] $java_bin                          = undef,
  Optional[String]               $jdbc_ssl_properties               = undef,
  Stdlib::Host                   $listen_address                    = 'localhost',
  Stdlib::Port                   $listen_port                       = 8080,
  String                         $log_slow_statements               = '10',
  Boolean                        $manage_config                     = true,
  Boolean                        $manage_database                   = true,
  Boolean                        $manage_db_password                = true,
  Boolean                        $manage_dbserver                   = true,
  Boolean                        $manage_dnf_module                 = $puppetdb::params::manage_dnf_module,
  Boolean                        $manage_firewall                   = true,
  Boolean                        $manage_package_repo               = true,
  Boolean                        $manage_read_db_password           = true,
  Boolean                        $manage_report_processor           = false,
  Boolean                        $manage_routes                     = true,
  Boolean                        $manage_server                     = true,
  Boolean                        $manage_storeconfigs               = true,
  Boolean                        $masterless                        = false,
  Optional[String]               $max_threads                       = undef,
  Boolean                        $merge_default_java_args           = true,
  Boolean                        $migrate                           = true,
  String                         $node_purge_gc_batch_limit         = '25',
  String                         $node_purge_ttl                    = '14d',
  String                         $node_ttl                          = '7d',
  Boolean                        $open_listen_port                  = false,
  Optional[Stdlib::Port]         $open_ssl_listen_port              = undef,
  Stdlib::Absolutepath           $postgresql_ssl_ca_cert_path       = $puppetdb::params::postgresql_ssl_ca_cert_path,
  Stdlib::Absolutepath           $postgresql_ssl_cert_path          = $puppetdb::params::postgresql_ssl_cert_path,
  Stdlib::Absolutepath           $postgresql_ssl_folder             = $puppetdb::params::postgresql_ssl_folder,
  Stdlib::Absolutepath           $postgresql_ssl_key_path           = $puppetdb::params::postgresql_ssl_key_path,
  Boolean                        $postgresql_ssl_on                 = false,
  String                         $postgres_version                  = $puppetdb::params::postgres_version,
  Stdlib::Absolutepath           $puppet_conf                       = $puppetdb::params::puppet_conf,
  Stdlib::Absolutepath           $puppet_confdir                    = $puppetdb::params::puppet_conf,
  String                         $puppet_service_name               = $puppetdb::params::puppet_service_name,
  Boolean                        $puppetdb_disable_ssl              = false,
  Stdlib::Absolutepath           $puppetdb_initconf                 = $puppetdb::params::puppetdb_initconf,
  Optional[Stdlib::Port]         $puppetdb_port                     = undef,
  String                         $puppetdb_group                    = $puppetdb::params::puppetdb_group,
  String                         $puppetdb_package                  = 'puppetdb',
  Stdlib::Host                   $puppetdb_server                   = fact('networking.fqdn'),
  String                         $puppetdb_service                  = 'puppetdb',
  String                         $puppetdb_version                  = $puppetdb::params::puppetdb_version,
  Enum['true','false','running','stopped']  $puppetdb_service_status  = 'running',
  Boolean                        $puppetdb_soft_write_failure       = false,
  Integer                        $puppetdb_startup_timeout          = 120,
  String                         $puppetdb_user                     = $puppetdb::params::puppetdb_user,
  String                         $read_conn_keep_alive              = '45',
  String                         $read_conn_lifetime                = '0',
  String                         $read_conn_max_age                 = '60',
  Optional[String]               $read_database_host                = undef,
  Optional[String]               $read_database_jdbc_ssl_properties = undef,
  Optional[String]               $read_database_max_pool_size       = undef,
  String                         $read_database_name                = 'puppetdb',
  String                         $read_database_password            = 'puppetdb-read',
  Stdlib::Port                   $read_database_port                = 5432,
  String                         $read_database                     = 'postgres',
  String                         $read_database_username            = 'puppetdb-read',
  Boolean                        $read_database_validate            = true,
  String                         $read_log_slow_statements          = '10',
  String                         $report_ttl                        = '14d',
  Boolean                        $restart_puppet                    = true,
  Stdlib::Absolutepath           $ssl_ca_cert_path                  = $puppetdb::params::ssl_ca_cert_path,
  Optional[String]               $ssl_ca_cert                       = undef,
  Stdlib::Absolutepath           $ssl_cert_path                     = $puppetdb::params::ssl_cert_path,
  Optional[String]               $ssl_cert                          = undef,
  Boolean                        $ssl_deploy_certs                  = false,
  Stdlib::Absolutepath           $ssl_dir                           = $puppetdb::params::ssl_dir,
  Stdlib::Absolutepath           $ssl_key_path                      = $puppetdb::params::ssl_key_path,
  Stdlib::Absolutepath           $ssl_key_pk8_path                  = $puppetdb::params::ssl_key_pk8_path,
  Optional[String]               $ssl_key                           = undef,
  Stdlib::IP::Address            $ssl_listen_address                = '0.0.0.0',
  Stdlib::Port                   $ssl_listen_port                   = 8081,
  Optional[Enum['TLSv1.2','TLSv1.3']]  $ssl_protocols               = undef,
  Boolean                        $ssl_set_cert_paths                = false,
  Optional[String]               $store_usage                       = undef,
  Boolean                        $strict_validation                 = true,
  Optional[String]               $temp_usage                        = undef,
  String                         $terminus_package                  = $puppetdb::params::terminus_package,
  String                         $test_url                          = '/v3/version',
  Stdlib::Absolutepath           $vardir                            = $puppetdb::params::vardir,
) {
  #
  class { 'puppetdb::server': }

  if $database == 'postgres' {
    class { 'puppetdb::database::postgresql': }
  }
}
