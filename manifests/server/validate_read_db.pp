# @summary This validates a database connection.
#
# @see README.md for more details.
#
# @param database
#   Which database backend to use; legal values are 'postgres' (default) or 'embedded'.
#   The 'embedded' option is not supported on PuppetDB 4.0.0 or later. 'embedded' can be used
#   for very small installations or for testing, but is not recommended for use in production
#   environments.
# @param database_host
#   Hostname to use for the database connection. For single case installations this should be
#   left as the default. Defaults to 'localhost', ignored for 'embedded' database.
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
# @param jdbc_ssl_properties
#   The text to append to the JDBC connection URI. This should begin with a '?' character.
#   For example, to use SSL for the PostgreSQL connection, set this parameter's value to
#   '?ssl=true'.
#
class puppetdb::server::validate_read_db (
  String            $database             = 'postgres',
  Stdlib::Host      $database_host        = 'localhost',
  Stdlib::Port      $database_port        = 5432,
  String            $database_username    = 'puppetdb',
  String            $database_password    = 'puppetdb',
  String            $database_name        = 'puppetdb',
  Optional[String]  $jdbc_ssl_properties  = undef,
) {
  # Debug code
  $debug_read_validate_db = @("EOC"/)
    \n
      Puppetdb::Server::Validate_read_db params
                                         database: ${database}
                                    database_host: ${database_host}
                                    database_port: ${database_port}
                                database_username: ${database_username}
                                database_password: ${database_password}
                                    database_name: ${database_name}
                              jdbc_ssl_properties: ${jdbc_ssl_properties}

    |- EOC
  # Uncomment the following resource to display values for all parameters.
  notify { "DEBUG_server_read_validate_db: ${debug_read_validate_db}": }

  # Currently we only support postgres
  if (
    $database == 'postgres' and
    ($database_password != undef and $jdbc_ssl_properties == false)
  ) {
    postgresql::validate_db_connection { 'validate puppetdb postgres (read) connection':
      database_host     => $database_host,
      database_port     => $database_port,
      database_username => $database_username,
      database_password => $database_password,
      database_name     => $database_name,
    }
  }
}
