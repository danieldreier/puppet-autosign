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

  $version = pick($::pe_server_version, $::pe_build, $::puppetversion)
  case $version {
    /^\d{4}\.\d+\.\d+$/: {
      # Puppet enterprise versionsing: 20xx.y.z
      $user           = 'pe-puppet'
      $group          = 'pe-puppet'
      $pe_journalpath = '/opt/puppetlabs/server/autosign'
      $pe_configpath  = '/etc/puppetlabs/puppetserver'
      $pe_logpath     = '/var/log/puppetlabs/puppetserver'
    }
    /^\d+\.\d+\.\d+$/: {
      # Normal versioning, assuming pe_build and pe_server_version don't exist
      $user  = 'puppet'
      $group = 'puppet'
    }
    default: { fail("::autosign::params cannot determine defaults for puppet version '${version}'") }
  }

  $ensure             = 'present'
  $base_logpath       = '/var/log'
  $gem_provider       = 'puppet_gem'
  $logpath            = pick($pe_logpath,     $base_logpath)
  $journalpath        = pick($pe_journalpath, $base_journalpath)
  $configpath         = pick($pe_configpath,  $base_configpath)
  $configfile         = "${configpath}/autosign.conf"
  $manage_journalfile = true
  $manage_logfile     = true
  $manage_package     = true
  $config             = Sensitive.new({
    'general'   => {
      'loglevel' => 'INFO',
      'logfile'  => "${logpath}/autosign.log",
    },
    'jwt_token' => {
      'validity'    => 7200,
      'journalfile' => "${journalpath}/autosign.journal",
      # THIS IS NOT SECURE! It is marginally better than harcoding a password,
      # but it can be replicated externaly to the Puppet Master.
      # Please override this. It will also cause multi-master setups to not work
      # correctly, all the more reason to override it.
      'secret'      => fqdn_rand_string(30),
    },
  })

}
