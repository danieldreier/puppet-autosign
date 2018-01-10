# Autosign Class.
#
# Implements the `autosign` gem to allow automated signing of certificates
#
# @summary Installs and configures the autosign gem.
#
# @example Declaring the class
#   class { ::autosign:
#     ensure   => 'latest',
#     settings => {
#       'general' => {
#         'loglevel' => 'INFO',
#       },
#       'jwt_token' => {
#         'secret'   => 'hunter2'
#         'validity' => '7200',
#       }
#     },
#   }
#
# @param package_name Name of the gem to install. Defaults to "autosign" and
#   there's probably no reason to override it.
#
# @param ensure Ensure parameter on the package to install. Set to "present",
#   "latest", "absent", or a specific gem version.
#
# @param configfile Path to the config file
#
# @param user User that should own the files, this should be user that the
#   Puppet server runs as.
#
# @param group Group that should own the config files
#
# @param journalpath Path to the journalfile, this will be managed as a
#   directory, with the journalfile placed under it.
#
# @param gem_provider Provide to use to the gem.
#
# @param manage_journalfile Weather or not to manage the journalfile
#
# @param manage_logfile Weather or not to manage the logfile
#
# @param settings Hash of setting to use.
#
class autosign (
  String               $ensure             = $::autosign::params::ensure,
  String               $package_name       = $::autosign::params::package_name,
  Stdlib::Absolutepath $configfile         = $::autosign::params::configfile,
  String               $user               = $::autosign::params::user,
  String               $group              = $::autosign::params::group,
  Stdlib::Absolutepath $journalpath        = $::autosign::params::journalpath,
  String               $gem_provider       = $::autosign::params::gem_provider,
  Boolean              $manage_journalfile = $::autosign::params::manage_journalfile,
  Boolean              $manage_logfile     = $::autosign::params::manage_logfile,
  Hash                 $settings           = {},
) inherits ::autosign::params {
  contain ::autosign::install
  contain ::autosign::config

  Class['::autosign::install']
  -> Class['::autosign::config']
}
