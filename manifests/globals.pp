# @summary Global configuration class for PuppetDB.
#
# @see README.md for more details.
#
# @param version
# @param database
#
class puppetdb::globals (
  String                       $version   = 'present',
  Enum['embedded','postgres']  $database  = 'postgres',
) {
  if !(fact('os.family') in ['RedHat', 'Suse', 'Archlinux', 'Debian', 'OpenBSD', 'FreeBSD']) {
    fail("${module_name} does not support your osfamily ${fact('os.family')}")
  }
}
