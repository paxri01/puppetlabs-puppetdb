# @summary Manage the installation of the report processor on the master.
#
# @api private
#
# @see README.md for more details.
#
class puppetdb::master::report_processor (
  Stdlib::Absolutepath  $puppet_conf   = $puppetdb::puppet_conf,
  Boolean               $masterless    = $puppetdb::masterless,
  Boolean               $enable        = $puppetdb::enable_reports,
) {
  # Debug params
  $debug_report_processor = @("EOC"/)
    \n
      Puppetdb::Master::Report_processor params

                                      puppet_conf: ${puppet_conf}
                                       masterless: ${masterless}
                                           enable: ${enable}

    | EOC
  # Uncomment the following resource to display values for all parameters.
  #notify { "DEBUG_master_report_processor: ${debug_report_processor}": }

  if $masterless {
    $puppet_conf_section = 'main'
  } else {
    $puppet_conf_section = 'master'
  }

  $puppetdb_ensure = $enable ? {
    true    => present,
    default => absent,
  }

  ini_subsetting { 'puppet.conf/reports/puppetdb':
    ensure               => $puppetdb_ensure,
    path                 => $puppet_conf,
    section              => $puppet_conf_section,
    setting              => 'reports',
    subsetting           => 'puppetdb',
    subsetting_separator => ',',
  }
}
