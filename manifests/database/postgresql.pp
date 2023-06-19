# @summary Class for creating the PuppetDB postgresql database. See README.md
#   for more information.
#
class puppetdb::database::postgresql {
  $database_name               = $puppetdb::database_name
  $database_password           = $puppetdb::database_password
  $database_port               = $puppetdb::database_port
  $database_username           = $puppetdb::database_username
  $listen_addresses            = $puppetdb::database_listen_address
  $manage_database             = $puppetdb::manage_database
  $manage_dnf_module           = $puppetdb::manage_dnf_module
  $manage_package_repo         = $puppetdb::manage_package_repo
  $manage_server               = $puppetdb::manage_dbserver
  $postgres_version            = $puppetdb::postgres_version
  $postgresql_ssl_ca_cert_path = $puppetdb::postgresql_ssl_ca_cert_path
  $postgresql_ssl_cert_path    = $puppetdb::postgresql_ssl_cert_path
  $postgresql_ssl_key_path     = $puppetdb::postgresql_ssl_key_path
  $postgresql_ssl_on           = $puppetdb::postgresql_ssl_on
  $puppetdb_server             = $puppetdb::puppetdb_server
  $read_database_host          = $puppetdb::read_database_host
  $read_database_password      = $puppetdb::read_database_password
  $read_database_username      = $puppetdb::read_database_username

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
      port                    => scanf($database_port, '%i')[0],
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
