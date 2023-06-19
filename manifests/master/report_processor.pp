# @summary Manage the installation of the report processor on the master.
#
# @see README.md for more details.
#
class puppetdb::master::report_processor {
  $puppet_conf = $puppetdb::puppet_conf
  $masterless  = $puppetdb::masterless
  $enable      = false

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
