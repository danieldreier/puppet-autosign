# == Class autosign::params
#
# This class is meant to be called from autosign.
# It sets variables according to platform.
#
class autosign::params {

  $ensure = 'present'
  case $::osfamily {
    'Debian', 'Ubuntu': {
      $package_name = 'autosign'
      $configfile   = '/etc/autosign.conf'
      $journalpath  = '/var/lib/autosign'
    }
    'RedHat', 'Amazon', 'sles', 'opensuse', 'OracleLinux', 'fedora': {
      $package_name = 'autosign'
      $configfile   = '/etc/autosign.conf'
      $journalpath  = '/var/lib/autosign'
    }
    'freebsd', 'openbsd': {
      $package_name = 'autosign'
      $configfile   = '/usr/local/etc/autosign.conf'
      $journalpath  = '/var/autosign'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  case $::puppetversion {
    /^3\.\d\.\d$/: {
      $gem_provider = 'gem'
      $user = 'puppet'
      $group = 'puppet'
    }
    /^[45]\.\d+\.\d+$/: {
      $gem_provider = 'puppet_gem'
      $user = 'puppet'
      $group = 'puppet'
    }
    /^.*\(Puppet Enterprise 3\.\d+\.\d+\)$/: {
      $gem_provider = 'pe_gem'
      $group = 'pe-puppet'
    }
    /^.*\(Puppet Enterprise \d+\.\d+\.\d+\)$/: {
      $gem_provider = 'puppet_gem'
      $group = 'pe-puppet'
    }
    default: { fail("::autosign::params cannot determine which gem provider to use with puppet version '${::puppetversion}'") }
  }

  $settings = {
    'general' =>
      {
        'loglevel' => 'INFO',
        'logfile'  => '/var/log/autosign.log',
      },
    'jwt_token' =>
    {
      'validity'    => 7200,
      'journalfile' => "${journalpath}/autosign.journal",
    }
  }
}
