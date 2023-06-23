# @summary A define type to manage the creation of a read-only postgres users.
#   In particular, it manages the necessary grants to enable such a user
#   to have read-only access to any existing objects as well as changes
#   the default access privileges so read-only access is maintained when
#   new objects are created by the $database_owner
#
# @api private
#
# @param read_database_username
#   [String] The name of the postgres read only user.
# @param database_name
#   [String] The name of the database to grant access to.
# @param database_owner
#   [String] The user which owns the database (i.e. the migration user for the database).
# @param password_hash
#   [String] The value of $_database_password in app_database.
#
define puppetdb::database::read_only_user (
  String                    $database_name           = $puppetdb::database_name,
  String                    $database_owner          = $puppetdb::database_owner,
  String                    $read_database_username  = $puppetdb::read_database_username,
  Variant[String, Boolean]  $password_hash           = $puppetdb::read_database_password,
) {
  # Debug params
  $debug_read_only_user = @("EOC"/)
    \n
      Puppetdb::Database::Read_only_user params

                                    database_name: ${database_name}
                                   database_owner: ${database_owner}
                           read_database_username: ${read_database_username}
                                    password_hash: ${password_hash}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  #notify { "DEBUG_database_default_read_grant: ${debug_read_only_user}": }

  postgresql::server::role { $read_database_username:
    password_hash => $password_hash,
  }

  -> postgresql::server::database_grant { "${database_name} grant connection permission to ${read_database_username}":
    privilege => 'CONNECT',
    db        => $database_name,
    role      => $read_database_username,
  }

  -> puppetdb::database::default_read_grant {
    "${database_name} grant read permission on new objects from ${database_owner} to ${read_database_username}":
      database_username           => $database_owner,
      database_read_only_username => $read_database_username,
      database_name               => $database_name,
      schema                      => 'public',
  }

  -> puppetdb::database::read_grant {
    "${database_name} grant read-only permission on existing objects to ${read_database_username}":
      database_read_only_username => $read_database_username,
      database_name               => $database_name,
      schema                      => 'public',
  }
}
