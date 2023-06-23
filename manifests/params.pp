# @summary The puppetdb default configuration settings.
#
# @api private
#
class puppetdb::params inherits puppetdb::globals {
  $puppetdb_version          = $puppetdb::globals::version
  $database                  = $puppetdb::globals::database

  if fact('os.family') =~ /RedHat|Debian/ {
    $manage_pg_repo            = true
  } else {
    $manage_pg_repo            = false
  }

  if fact('os.family') == 'RedHat' and versioncmp(fact('os.release.major'), '8') >= 0 {
    $manage_dnf_module         = true
  } else {
    $manage_dnf_module         = false
  }

  if $puppetdb_version in ['latest','present'] or versioncmp($puppetdb_version, '7.0.0') >= 0 {
    $postgres_version          = '11'
  } else {
    $postgres_version          = '9.6'
  }

  if !($puppetdb_version in ['latest','present','absent']) and versioncmp($puppetdb_version, '3.0.0') < 0 {
    case fact('os.family') {
      'RedHat', 'Suse', 'Archlinux','Debian': {
        $etcdir                 = '/etc/puppetdb'
        $vardir                 = '/var/lib/puppetdb'
        $database_embedded_path = "${vardir}/db/db"
        $puppet_confdir         = pick($settings::confdir,'/etc/puppetlabs/puppet')
        $puppet_service_name    = 'puppetmaster'
      }
      'OpenBSD': {
        $etcdir                 = '/etc/puppetdb'
        $vardir                 = '/var/db/puppetdb'
        $database_embedded_path = "${vardir}/db/db"
        $puppet_confdir         = pick($settings::confdir,'/etc/puppetlabs/puppet')
        $puppet_service_name    = 'puppetmasterd'
      }
      'FreeBSD': {
        $etcdir                 = '/usr/local/etc/puppetdb'
        $vardir                 = '/var/db/puppetdb'
        $database_embedded_path = "${vardir}/db/db"
        $puppet_confdir         = pick($settings::confdir,'/usr/local/etc/puppetlabs/puppet')
        $puppet_service_name    = 'puppetmaster'
      }
      default: {
        fail("The fact 'os.family' is set to ${fact('os.family')} which is not supported by the puppetdb module.")
      }
    }
    $terminus_package = 'puppetdb-terminus'
    $test_url         = '/v3/version'
  } else {
    case fact('os.family') {
      'RedHat', 'Suse', 'Archlinux','Debian': {
        $etcdir              = '/etc/puppetlabs/puppetdb'
        $puppet_confdir      = pick($settings::confdir,'/etc/puppetlabs/puppet')
        $puppet_service_name = 'puppetserver'
      }
      'OpenBSD': {
        $etcdir              = '/etc/puppetlabs/puppetdb'
        $puppet_confdir      = pick($settings::confdir,'/etc/puppetlabs/puppet')
        $puppet_service_name = undef
      }
      'FreeBSD': {
        $etcdir              = '/usr/local/etc/puppetlabs/puppetdb'
        $puppet_confdir      = pick($settings::confdir,'/usr/local/etc/puppetlabs/puppet')
        $puppet_service_name = undef
      }
      default: {
        fail("The fact 'os.family' is set to ${fact('os.family')} which is not supported by the puppetdb module.")
      }
    }
    $database_embedded_path = "${vardir}/db/db"
    $terminus_package       = 'puppetdb-termini'
    $test_url               = '/pdb/meta/v1/version'
    $vardir                 = '/opt/puppetlabs/server/data/puppetdb'
  }

  case fact('os.family') {
    'RedHat', 'Suse', 'Archlinux': {
      $puppetdb_user     = 'puppetdb'
      $puppetdb_group    = 'puppetdb'
      $puppetdb_initconf = '/etc/sysconfig/puppetdb'
    }
    'Debian': {
      $puppetdb_user     = 'puppetdb'
      $puppetdb_group    = 'puppetdb'
      $puppetdb_initconf = '/etc/default/puppetdb'
    }
    'OpenBSD': {
      $puppetdb_user     = '_puppetdb'
      $puppetdb_group    = '_puppetdb'
      $puppetdb_initconf = undef
    }
    'FreeBSD': {
      $puppetdb_user     = 'puppetdb'
      $puppetdb_group    = 'puppetdb'
      $puppetdb_initconf = undef
    }
    default: {
      fail("The fact 'os.family' is set to ${fact('os.family')} which is not supported by the puppetdb module.")
    }
  }

  $certificate_whitelist_file   = "${etcdir}/certificate-whitelist"
  $confdir                      = "${etcdir}/conf.d"
  $ssl_dir                      = "${etcdir}/ssl"
  $puppet_conf                  = "${puppet_confdir}/puppet.conf"

  # certificats used for PostgreSQL SSL configuration. Puppet certificates are used
  $postgresql_ssl_folder        = "${puppet_confdir}/ssl"
  $postgresql_ssl_cert_path     = "${postgresql_ssl_folder}/certs/${trusted['certname']}.pem"
  $postgresql_ssl_key_path      = "${postgresql_ssl_folder}/private_keys/${trusted['certname']}.pem"
  $postgresql_ssl_ca_cert_path  = "${postgresql_ssl_folder}/certs/ca.pem"

  # certificats used for Jetty configuration
  $ssl_cert_path                = "${ssl_dir}/public.pem"
  $ssl_key_path                 = "${ssl_dir}/private.pem"
  $ssl_ca_cert_path             = "${ssl_dir}/ca.pem"

  # certificate used by PuppetDB SSL Configuration
  $ssl_key_pk8_path             = regsubst($ssl_key_path, '.pem', '.pk8')

  # Get the parameter name for the database connection pool tuning
  if $puppetdb_version in ['latest','present'] or versioncmp($puppetdb_version, '4.0.0') >= 0 {
    $database_max_pool_size_setting_name = 'maximum-pool-size'
  } elsif versioncmp($puppetdb_version, '2.8.0') >= 0 {
    $database_max_pool_size_setting_name = 'partition-conn-max'
  } else {
    $database_max_pool_size_setting_name = undef
  }
}
