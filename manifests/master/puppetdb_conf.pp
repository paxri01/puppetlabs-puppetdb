# @summary Manage the puppetdb.conf file on the puppeet master.
#
# @see README.md for more details.
#
# @param server
#   The dns name or ip of the PuppetDB server. Defaults to the hostname of the current node,
#   i.e. '$::fqdn'.
# @param port
#   The port that the PuppetDB server is running on. Defaults to '8081'.
# @param puppet_confdir
#   Puppet's config directory. Defaults to '/etc/puppetlabs/puppetdb'.
#
class puppetdb::master::puppetdb_conf (
  Stdlib::Host          $server             = 'localhost',
  Stdlib::Port          $port               = 8081,
  Stdlib::Absolutepath  $puppet_confdir     = '/etc/puppetlabs/puppetdb',
) {
  $soft_write_failure = $puppetdb::disable_ssl ? {
    true => true,
    default => false,
  }
  $legacy_terminus    = $puppetdb::terminus_package ? {
    /(puppetdb-terminus)/ => true,
    default               => false,
  }

  # Debug params
  $debug_puppetdb_conf = @("EOC"/)
    \n
      puppetdb::master::puppetdb_conf params

                                   puppet_confdir: ${puppet_confdir}
                                           server: ${server}
                                             port: ${port}
                               soft_write_failure: ${soft_write_failure}
                                  legacy_terminus: ${legacy_terminus}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  notify { "DEBUG_master_puppetdb_conf: ${debug_puppetdb_conf}": }

  Ini_setting {
    ensure  => present,
    section => 'main',
    path    => "${puppet_confdir}/puppetdb.conf",
  }

  if $legacy_terminus {
    ini_setting { 'puppetdbserver':
      setting => 'server',
      value   => $server,
    }
    ini_setting { 'puppetdbport':
      setting => 'port',
      value   => $port,
    }
  } else {
    ini_setting { 'puppetdbserver_urls':
      setting => 'server_urls',
      value   => "https://${server}:${port}/",
    }
  }

  ini_setting { 'soft_write_failure':
    setting => 'soft_write_failure',
    value   => $soft_write_failure,
  }
}
