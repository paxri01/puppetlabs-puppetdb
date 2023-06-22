# @summary  Grant read permissions to $database_read_only_username by default,
#   for new tables created by $database_username.
#
# @api private
#
define puppetdb::database::default_read_grant (
  String    $database_name                = 'puppetdb',
  String    $schema                       = 'public',
  String    $database_username            = 'puppetdb',
  String    $database_read_only_username  = 'puppetdb-read',
) {
  # Debug params
  $debug_default_read_grant = @("EOC"/)
    \n
      Puppetdb::Database::Default_read_grant params

                                    database_name: ${database_name}
                                           schema: ${schema}
                                database_username: ${database_username}
                      database_read_only_username: ${database_read_only_username}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  notify { "DEBUG_database_default_read_grant: ${debug_default_read_grant}": }

  postgresql_psql { "grant default select permission for ${database_read_only_username}":
    db      => $database_name,
    command => "ALTER DEFAULT PRIVILEGES
                  FOR USER \"${database_username}\"
                  IN SCHEMA \"${schema}\"
                GRANT SELECT ON TABLES
                  TO \"${database_read_only_username}\"",
    unless  => "SELECT
                  ns.nspname,
                  acl.defaclobjtype,
                  acl.defaclacl
                FROM pg_default_acl acl
                JOIN pg_namespace ns ON acl.defaclnamespace=ns.oid
                WHERE acl.defaclacl::text ~ '.*\\\\\"${database_read_only_username}\\\\\"=r/${database_username}\\\".*'
                AND nspname = '${schema}'",
  }

  postgresql_psql { "grant default usage permission for ${database_read_only_username}":
    db      => $database_name,
    command => "ALTER DEFAULT PRIVILEGES
                  FOR USER \"${database_username}\"
                  IN SCHEMA \"${schema}\"
                GRANT USAGE ON SEQUENCES
                  TO \"${database_read_only_username}\"",
    unless  => "SELECT
                  ns.nspname,
                  acl.defaclobjtype,
                  acl.defaclacl
                FROM pg_default_acl acl
                JOIN pg_namespace ns ON acl.defaclnamespace=ns.oid
                WHERE acl.defaclacl::text ~ '.*\\\\\"${database_read_only_username}\\\\\"=U/${database_username}\\\".*'
                AND nspname = '${schema}'",
  }

  postgresql_psql { "grant default execute permission for ${database_read_only_username}":
    db      => $database_name,
    command => "ALTER DEFAULT PRIVILEGES
                  FOR USER \"${database_username}\"
                  IN SCHEMA \"${schema}\"
                GRANT EXECUTE ON FUNCTIONS
                  TO \"${database_read_only_username}\"",
    unless  => "SELECT
                  ns.nspname,
                  acl.defaclobjtype,
                  acl.defaclacl
                FROM pg_default_acl acl
                JOIN pg_namespace ns ON acl.defaclnamespace=ns.oid
                WHERE acl.defaclacl::text ~ '.*\\\\\"${database_read_only_username}\\\\\"=X/${database_username}\\\".*'
                AND nspname = '${schema}'",
  }
}
