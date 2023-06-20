# @summary Manages the routes configuration file on the master.
#
# @see README.md for more details.
#
# @param puppet_confdir
# @param masterless
# @param routes
#
class puppetdb::master::routes (
  Stdlib::Absolutepath     $puppet_confdir   = $puppetdb::params::puppet_confdir,
  Boolean                  $masterless       = false,
  Optional[String]         $routes           = undef,
) inherits puppetdb::params {
  # Debug params
  $debug_routes = @("EOC"/)
    \n
    puppetdb::master::routes params
      puppet_confdir: ${puppet_confdir}
          masterless: ${masterless}
              routes: ${routes}

    | EOC
  notify { "DEBUG_master_routes: ${debug_routes}": }

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
