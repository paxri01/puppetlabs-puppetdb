# @summary This class configures the puppet master to enable storeconfigs and to use
#   puppetdb as the storeconfigs backend.
#
# @api private
#
# @see README.md for more details.
#
class puppetdb::master::storeconfigs (
  Stdlib::Absolutepath  $puppet_conf   = $puppetdb::puppet_conf,
  Boolean               $masterless    = $puppetdb::masterless,
  Boolean               $enable        = $puppetdb::enable_storeconfigs,
) {
  # Debug params
  $debug_storeconfigs = @("EOC"/)
    \n
      Puppetdb::Master::Storeconfigs

                                      puppet_conf: ${puppet_conf}
                                       masterless: ${masterless}
                                           enable: ${enable}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  #notify { "DEBUG_master_storeconfigs: ${debug_storeconfigs}": }

  if $masterless {
    $puppet_conf_section = 'main'
  } else {
    $puppet_conf_section = 'master'
  }

  $storeconfigs_ensure = $enable ? {
    true    => present,
    default => absent,
  }

  Ini_setting {
    section => $puppet_conf_section,
    path    => $puppet_conf,
    ensure  => $storeconfigs_ensure,
  }

  ini_setting { "puppet.conf/${puppet_conf_section}/storeconfigs":
    setting => 'storeconfigs',
    value   => true,
  }

  ini_setting { "puppet.conf/${puppet_conf_section}/storeconfigs_backend":
    setting => 'storeconfigs_backend',
    value   => 'puppetdb',
  }
}
