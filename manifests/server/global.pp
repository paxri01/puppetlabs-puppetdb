# @summary PRIVATE CLASS - do not use directly
#
# @api private
#
class puppetdb::server::global {
  $confdir        = $puppetdb::confdir
  $puppetdb_group = $puppetdb::puppetdb_group
  $puppetdb_user  = $puppetdb::puppetdb_user
  $vardir         = $puppetdb::vardir

  $config_ini = "${confdir}/config.ini"

  file { $config_ini:
    ensure => file,
    owner  => $puppetdb_user,
    group  => $puppetdb_group,
    mode   => '0600',
  }

  # Set the defaults
  Ini_setting {
    path    => $config_ini,
    ensure  => 'present',
    section => 'global',
    require => File[$config_ini],
  }

  if $vardir {
    ini_setting { 'puppetdb_global_vardir':
      setting => 'vardir',
      value   => $vardir,
    }
  }
}
