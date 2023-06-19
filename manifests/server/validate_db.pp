# @summary This validates a database connection.
#
# @see README.md for more details.
#
class puppetdb::server::validate_db {
  $database            = $puppetdb::database
  $database_host       = $puppetdb::database_host
  $database_port       = $puppetdb::database_port
  $database_username   = $puppetdb::database_username
  $database_password   = $puppetdb::database_password
  $database_name       = $puppetdb::database_name
  $jdbc_ssl_properties = $puppetdb::jdbc_ssl_properties

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
