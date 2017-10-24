# Class: autosign
# ===========================
#
# Full description of class autosign here.
#
# Parameters
# ----------
#
# * `package_name`
#   Name of the gem to install. Defaults to "autosign" and there's probably no
#   reason to override it.
#
# * `ensure`
#   Ensure parameter on the package to install. Set to "present", "latest",
#   "absent", or a specific gem version.
#
class autosign (
  String               $package_name,
  Stdlib::Absolutepath $configfile,
  String               $ensure,
  String               $user,
  String               $group,
  Stdlib::Absolutepath $journalpath,
  String               $gem_provider,
  String               $settings_loglevel,
  Stdlib::Absolutepath $settings_logfile,
  Integer              $settings_validity,
  String               $settings_journalfile,
) {
  if $facts['pe_build'] {
    $user  = 'pe-puppet'
    $group = 'pe-puppet'
  } else {
    $user  = 'puppet'
    $group = 'puppet'
  }

  contain ::autosign::install
  contain ::autosign::config

  Class['::autosign::install']
  -> Class['::autosign::config']
}
