# @summary PRIVATE CLASS - do not use directly
#
# @api private
#
class puppetdb::server::puppetdb {
  $certificate_whitelist      = $puppetdb::certificate_whitelist
  $certificate_whitelist_file = $puppetdb::certificate_whitelist_file
  $confdir                    = $puppetdb::confdir
  $disable_update_checking    = $puppetdb::disable_update_checking
  $puppetdb_group             = $puppetdb::puppetdb_group
  $puppetdb_user              = $puppetdb::puppetdb_user

  $puppetdb_ini = "${confdir}/puppetdb.ini"

  file { $puppetdb_ini:
    ensure => file,
    owner  => $puppetdb_user,
    group  => $puppetdb_group,
    mode   => '0600',
  }

  # Set the defaults
  Ini_setting {
    path    => $puppetdb_ini,
    ensure  => present,
    section => 'puppetdb',
    require => File[$puppetdb_ini],
  }

  $certificate_whitelist_setting_ensure = empty($certificate_whitelist) ? {
    true    => 'absent',
    default => 'present',
  }

  # accept connections only from puppet master
  ini_setting { 'puppetdb-connections-from-master-only':
    ensure  => $certificate_whitelist_setting_ensure,
    section => 'puppetdb',
    setting => 'certificate-whitelist',
    value   => $certificate_whitelist_file,
  }

  file { $certificate_whitelist_file:
    ensure  => $certificate_whitelist_setting_ensure,
    content => template('puppetdb/certificate-whitelist.erb'),
    mode    => '0644',
    owner   => 0,
    group   => 0,
  }

  if $disable_update_checking {
    ini_setting { 'puppetdb_disable_update_checking':
      setting => 'disable-update-checking',
      value   => $disable_update_checking,
    }
  } else {
    ini_setting { 'puppetdb_disable_update_checking':
      ensure  => 'absent',
      setting => 'disable-update-checking',
    }
  }
}
