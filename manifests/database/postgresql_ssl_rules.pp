# @summary class for configuring the pg_ident.conf and pg_hba.conf files
#
# @api private
#
define puppetdb::database::postgresql_ssl_rules (
  String    $database_name      = 'puppetdb',
  String    $database_username  = 'puppetdb',
  String    $puppetdb_server    = $facts['networking']['fqdn'],
) {
  # Debug params
  $debug_ssl_rules = @("EOC"/)
    \n
      Puppetdb::Database::Postgresql_ssl_rules params

                                    database_name: ${database_name}
                                database_username: ${database_username}
                                  puppetdb_server: ${puppetdb_server}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  notify { "DEBUG_database_read_grant: ${debug_ssl_rules}": }

  $identity_map_key = "${database_name}-${database_username}-map"

  postgresql::server::pg_hba_rule { "Allow certificate mapped connections to ${database_name} as ${database_username} (ipv4)":
    type        => 'hostssl',
    database    => $database_name,
    user        => $database_username,
    address     => '0.0.0.0/0',
    auth_method => 'cert',
    order       => 0,
    auth_option => "map=${identity_map_key} clientcert=1",
  }

  postgresql::server::pg_hba_rule { "Allow certificate mapped connections to ${database_name} as ${database_username} (ipv6)":
    type        => 'hostssl',
    database    => $database_name,
    user        => $database_username,
    address     => '::0/0',
    auth_method => 'cert',
    order       => 0,
    auth_option => "map=${identity_map_key} clientcert=1",
  }

  postgresql::server::pg_ident_rule { "Map the SSL certificate of the server as a ${database_username} user":
    map_name          => $identity_map_key,
    system_username   => $puppetdb_server,
    database_username => $database_username,
  }
}
