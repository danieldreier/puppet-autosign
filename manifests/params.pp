# == Class autosign::params
#
# This class is meant to be called from autosign.
# It sets variables according to platform.
#
class autosign::params {
  case $::osfamily {
    'Debian', 'Ubuntu': {
      $package_name     = 'autosign'
      $base_configpath  = '/etc'
      $base_journalpath = '/var/lib/autosign'
    }
    'RedHat', 'Amazon', 'sles', 'opensuse', 'OracleLinux', 'fedora': {
      $package_name     = 'autosign'
      $base_configpath  = '/etc'
      $base_journalpath = '/var/lib/autosign'
    }
    'freebsd', 'openbsd': {
      $package_name     = 'autosign'
      $base_configpath  = '/usr/local/etc'
      $base_journalpath = '/var/autosign'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  case pick($::pe_build, $::pe_server_version, $::puppetversion) {
    /^3\.\d\.\d$/: {
      $gem_provider = 'gem'
      $user         = 'puppet'
      $group        = 'puppet'
    }
    /^[45]\.\d+\.\d+$/: {
      $gem_provider = 'puppet_gem'
      $user         = 'puppet'
      $group        = 'puppet'
    }
    /^.*\(Puppet Enterprise 3\.\d+\.\d+\)$/: {
      $gem_provider   = 'pe_gem'
      $user           = 'pe-puppet'
      $group          = 'pe-puppet'
      $pe_journalpath = '/opt/puppetlabs/server'
      $pe_configpath  = '/etc/puppetlabs/puppetserver'
      $pe_logpath     = '/var/log/puppetlabs/puppetserver'
    }
    /^.*\(Puppet Enterprise \d+\.\d+\.\d+\)$/: {
      $gem_provider   = 'puppet_gem'
      $user           = 'pe-puppet'
      $group          = 'pe-puppet'
      $pe_journalpath = '/opt/puppetlabs/server'
      $pe_configpath  = '/etc/puppetlabs/puppetserver'
      $pe_logpath     = '/var/log/puppetlabs/puppetserver'
    }
    /^\d{4}\.\d+\.\d+$/: {
      $gem_provider   = 'puppet_gem'
      $user           = 'pe-puppet'
      $group          = 'pe-puppet'
      $pe_journalpath = '/opt/puppetlabs/server'
      $pe_configpath  = '/etc/puppetlabs/puppetserver'
      $pe_logpath     = '/var/log/puppetlabs/puppetserver'
    }
    default: { fail("::autosign::params cannot determine which gem provider to use with puppet version '${::puppetversion}'") }
  }

  $ensure             = 'present'
  $base_logpath       = '/var/log/'
  $logpath            = pick($pe_logpath,     $base_logpath)
  $journalpath        = pick($pe_journalpath, $base_journalpath)
  $configpath         = pick($pe_configpath,  $base_configpath)
  $configfile         = "${configpath}/autosign.conf"
  $manage_journalfile = true
  $manage_logfile     = true
  $settings           = {
    'general'   => {
      'loglevel' => 'INFO',
      'logfile'  => "${logpath}/autosign.log",
    },
    'jwt_token' => {
      'validity'    => 7200,
      'journalfile' => "${journalpath}/autosign.journal",
    },
  }

}
