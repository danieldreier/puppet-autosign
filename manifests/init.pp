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
  $package_name       = $::autosign::params::package_name,
  $configfile         = $::autosign::params::configfile,
  $ensure             = $::autosign::params::ensure,
  $user               = $::autosign::params::user,
  $group              = $::autosign::params::group,
  $journalpath        = $::autosign::params::journalpath,
  $gem_provider       = $::autosign::params::gem_provider,
  $manage_journalfile = $::autosign::params::manage_journalfile,
  $manage_logfile     = $::autosign::params::manage_logfile,
  $settings           = {},
) inherits ::autosign::params {
  validate_string($package_name)
  validate_string($ensure)

  contain ::autosign::install
  contain ::autosign::config

  Class['::autosign::install']
  -> Class['::autosign::config']
}
