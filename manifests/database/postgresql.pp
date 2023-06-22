# @summary Class for creating the PuppetDB postgresql database. See README.md
#   for more information.
#
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
# @param listen_addresses
#   The address that the web server should bind to for HTTP requests. Defaults to
#   'localhost'. Set to '0.0.0.0' to listen on all addresses.
# @param manage_database
#   If true, the PostgreSQL database will be managed by this module. Defaults to 'true'.
# @param manage_dnf_module
#   If 'true', enable specified postgresql version appstream for EL 8 systems. Also override
#   $server_package_name within postgresql module.  Defaults to false.
# @param manage_package_repo
#   If 'true', the official postgresql.org repo will be added and postgres won't be installed
#   from the regular repository. Defaults to 'true'.
# @param manage_server
#   Conditionally manages the PostgreSQL server via 'postgresql::server'. Defaults to 'true'.
#   If set to 'false', this class will create the database and user via 'postgresql::server::db'
#   but not attempt to install or manage the server itself.
# @param postgres_version
#   If the postgresql.org repo is installed, you can install several versions of postgres.
#   Defaults to '9.6' in module version 6.0+ and '9.4' in older versions.
# @param postgresql_ssl_ca_cert_path
# @param postgresql_ssl_cert_path
# @param postgresql_ssl_key_path
# @param postgresql_ssl_on
# @param puppetdb_server
#   The dns name or ip of the PuppetDB server. Defaults to the hostname of the current node,
#   i.e. '$::fqdn'.
# @param read_database_host
#   *This parameter must be set to use another PuppetDB instance for queries.*
#
#   The hostname or IP address of the read database server. If set to 'undef', and
#   'manage_database' is set to 'true', it will use the value of the 'database_host'
#   parameter. This option is supported in PuppetDB >= 1.6.
# @param read_database_password
#   The password for the read database user. Defaults to 'puppetdb-read'. This option is
#   supported in PuppetDB >= 1.6.
# @param read_database_username
#   The name of the read database user to connect as. Defaults to 'puppetdb-read'.
#   This option is supported in PuppetDB >= 1.6.
#
class puppetdb::database::postgresql (
  String                 $database_name                = 'puppetdb',
  String                 $database_password            = 'puppetdb',
  Stdlib::Port           $database_port                = 5432,
  String                 $database_username            = 'puppetdb',
  Stdlib::Host           $listen_addresses             = 'localhost',
  Boolean                $manage_database              = true,
  Boolean                $manage_dnf_module            = $puppetdb::params::manage_dnf_module,
  Boolean                $manage_package_repo          = true,
  Boolean                $manage_server                = true,
  String                 $postgres_version             = $puppetdb::params::postgres_version,
  Stdlib::Absolutepath   $postgresql_ssl_ca_cert_path  = $puppetdb::params::postgresql_ssl_ca_cert_path,
  Stdlib::Absolutepath   $postgresql_ssl_cert_path     = $puppetdb::params::postgresql_ssl_cert_path,
  Stdlib::Absolutepath   $postgresql_ssl_key_path      = $puppetdb::params::postgresql_ssl_key_path,
  Boolean                $postgresql_ssl_on            = false,
  Stdlib::Host           $puppetdb_server              = fact('networking.fqdn'),
  Optional[String]       $read_database_host           = undef,
  String                 $read_database_password       = 'puppetdb-read',
  String                 $read_database_username       = 'puppetdb-read',
) {
  # Debug params
  $debug_postgresql = @("EOC"/)
    \n
      Puppetdb::Database::Postgresql params

                                    database_name: ${database_name}
                                database_password: ${database_password}
                                    database_port: ${database_port}
                                database_username: ${database_username}
                                 listen_addresses: ${listen_addresses}
                                  manage_database: ${manage_database}
                                manage_dnf_module: ${manage_dnf_module}
                              manage_package_repo: ${manage_package_repo}
                                    manage_server: ${manage_server}
                                 postgres_version: ${postgres_version}
                      postgresql_ssl_ca_cert_path: ${postgresql_ssl_ca_cert_path}
                         postgresql_ssl_cert_path: ${postgresql_ssl_cert_path}
                          postgresql_ssl_key_path: ${postgresql_ssl_key_path}
                                postgresql_ssl_on: ${postgresql_ssl_on}
                                  puppetdb_server: ${puppetdb_server}
                               read_database_host: ${read_database_host}
                           read_database_password: ${read_database_password}
                           read_database_username: ${read_database_username}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  notify { "DEBUG_database_postgresql: ${debug_postgresql}": }

  if $manage_server {
    class { 'postgresql::globals':
      manage_dnf_module   => $manage_dnf_module,
      manage_package_repo => $manage_package_repo,
      version             => $postgres_version,
    }
    # get the pg server up and running
    class { 'postgresql::server':
      ip_mask_allow_all_users => '0.0.0.0/0',
      listen_addresses        => $listen_addresses,
      port                    => $database_port,
    }

    # We need to create the ssl connection for the read user, when
    # manage_database is set to true, or when read_database_host is defined.
    # Otherwise we don't create it.
    if $manage_database or $read_database_host != undef {
      $create_read_user_rule = true
    } else {
      $create_read_user_rule = false
    }

    # configure PostgreSQL communication with Puppet Agent SSL certificates if
    # postgresql_ssl_on is set to true
    if $postgresql_ssl_on {
      class { 'puppetdb::database::ssl_configuration': }
    }

    # Only install pg_trgm extension, if database it is actually managed by the module
    if $manage_database {
      # get the pg contrib to use pg_trgm extension
      class { 'postgresql::server::contrib': }

      postgresql::server::extension { 'pg_trgm':
        database => $database_name,
        require  => Postgresql::Server::Db[$database_name],
      }
    }
  }

  if $manage_database {
    # create the puppetdb database
    postgresql::server::db { $database_name:
      user     => $database_username,
      password => $database_password,
      grant    => 'all',
    }

    -> postgresql_psql { 'revoke all access on public schema':
      db      => $database_name,
      command => 'REVOKE CREATE ON SCHEMA public FROM public',
      unless  => "SELECT * FROM
                  (SELECT has_schema_privilege('public', 'public', 'create') can_create) privs
                WHERE privs.can_create=false",
    }

    -> postgresql_psql { "grant all permissions to ${database_username}":
      db      => $database_name,
      command => "GRANT CREATE ON SCHEMA public TO \"${database_username}\"",
      unless  => "SELECT * FROM
                  (SELECT has_schema_privilege('${database_username}', 'public', 'create') can_create) privs
                WHERE privs.can_create=true",
    }

    -> puppetdb::database::read_only_user { $read_database_username:
      read_database_username => $read_database_username,
      database_name          => $database_name,
      password_hash          => postgresql::postgresql_password($read_database_username, $read_database_password),
      database_owner         => $database_username,
    }

    -> postgresql_psql { "grant ${read_database_username} role to ${database_username}":
      db      => $database_name,
      command => "GRANT \"${read_database_username}\" TO \"${database_username}\"",
      unless  => "SELECT oid, rolname FROM pg_roles WHERE
                   pg_has_role( '${database_username}', oid, 'member') and rolname = '${read_database_username}'";
    }
  }
}
