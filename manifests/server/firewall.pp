# @summary PRIVATE CLASS - do not use directly
#
# @api private
#
class puppetdb::server::firewall {
  $http_port      = $puppetdb::listen_port
  $open_http_port = $puppetdb::open_listen_port
  $ssl_port       = $puppetdb::ssl_listen_port
  $open_ssl_port  = $puppetdb::open_ssl_listen_port

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
