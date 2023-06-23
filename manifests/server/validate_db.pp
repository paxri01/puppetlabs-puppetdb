# @summary This validates a database connection.
#
# @api private
#
# @see README.md for more details.
#
class puppetdb::server::validate_db (
  String                 $database              = $puppetdb::database,
  Stdlib::Host           $database_host         = $puppetdb::database_host,
  String                 $database_name         = $puppetdb::database_name,
  String                 $database_password     = $puppetdb::database_password,
  Stdlib::Port           $database_port         = $puppetdb::database_port,
  String                 $database_username     = $puppetdb::database_username,
  Optional[String]       $jdbc_ssl_properties   = $puppetdb::jdbc_ssl_properties,
) {
  # Debug code
  $debug_validate_db = @("EOC"/)
    \n
    Puppetdb::Server::Validate_db params
                                         database: ${database}
                                    database_host: ${database_host}
                                    database_port: ${database_port}
                                database_username: ${database_username}
                                database_password: ${database_password}
                                    database_name: ${database_name}
                              jdbc_ssl_properties: ${jdbc_ssl_properties}

    |- EOC
  # Uncomment the following resource to display values for all parameters.
  #notify { "DEBUG_server_validate_db: ${debug_validate_db}": }

  # We don't need any validation for the embedded database, presumably.
  if (
    $database == 'postgres' and
    ($database_password != undef and $jdbc_ssl_properties == false)
  ) {
    postgresql::validate_db_connection { 'validate puppetdb postgres connection':
      database_host     => $database_host,
      database_port     => $database_port,
      database_username => $database_username,
      database_password => $database_password,
      database_name     => $database_name,
    }
  }
}
