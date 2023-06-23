# @summary Manages the routes configuration file on the master.
#
# @api private
#
# @see README.md for more details.
#
class puppetdb::master::routes (
  Stdlib::Absolutepath     $puppet_confdir   = $puppetdb::puppet_confdir,
  Boolean                  $masterless       = $puppetdb::masterless,
  Optional[String]         $routes           = undef,
) {
  if $masterless {
    $routes_real = {
      'apply' => {
        'catalog' => {
          'terminus' => 'compiler',
          'cache'    => 'puppetdb',
        },
        'facts'   => {
          'terminus' => 'facter',
          'cache'    => 'puppetdb_apply',
        },
      },
    }
  } elsif $routes {
    $routes_real = $routes
  } else {
    if (defined('$serverversion')) and (versioncmp($serverversion, '7.0') >= 0) {
      $default_fact_cache = 'json'
    } else {
      $default_fact_cache = 'yaml'
    }
    $routes_real = {
      'master' => {
        'facts' => {
          'terminus' => 'puppetdb',
          'cache'    => $default_fact_cache,
        },
      },
    }
  }

  # Debug params
  $debug_routes = @("EOC"/)
    \n
      Puppetdb::Master::Routes params

                                   puppet_confdir: ${puppet_confdir}
                                       masterless: ${masterless}
                                           routes: ${routes}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  #notify { "DEBUG_master_routes: ${debug_routes}": }

  # TODO: this will overwrite any existing routes.yaml;
  #  to handle this properly we should just be ensuring
  #  that the proper settings exist, but to do that we'd need
  #  to parse the yaml file and rewrite it, dealing with indentation issues etc
  #  I don't think there is currently a puppet module or an augeas lens for
  #  this.
  file { "${puppet_confdir}/routes.yaml":
    ensure  => 'file',
    content => template('puppetdb/routes.yaml.erb'),
    mode    => '0644',
  }
}
