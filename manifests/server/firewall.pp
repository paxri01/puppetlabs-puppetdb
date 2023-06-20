# @summary PRIVATE CLASS - do not use directly
#
# @api private
#
# @note This class should be updated to use firewalld vs. firewall.
#
class puppetdb::server::firewall (
  Stdlib::Port             $http_port       = 8080,
  Boolean                  $open_http_port  = false,
  Stdlib::Port             $ssl_port        = 8081,
  Optional[Stdlib::Port]   $open_ssl_port   = undef,
) {
  # Debug params
  $debug_firewall = @("EOC"/)
    \n
      Puppetdb::Server::Firewall params

                                        http_port: ${http_port}
                                 open_listen_port: ${open_http_port}
                                  ssl_listen_port: ${ssl_port}
                             open_ssl_listen_port: ${open_ssl_port}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  notify { "DEBUG_server_firewall: ${debug_firewall}": }

  include firewall

  if ($open_http_port) {
    firewall { "${http_port} accept - puppetdb":
      dport  => $http_port,
      proto  => 'tcp',
      action => 'accept',
    }
  }

  if ($open_ssl_port) {
    firewall { "${ssl_port} accept - puppetdb":
      dport  => $ssl_port,
      proto  => 'tcp',
      action => 'accept',
    }
  }
}
