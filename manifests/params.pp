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

  if str2bool($::is_pe) {
    #Assuming PE 3
    $gem_provider = 'pe_gem'
    $group,$user = 'pe-puppet'
  } else {
    if $::puppetversion and versioncmp($::puppetversion, '4.0.0') >= 0 {
      if $::pe_server_version
      {
        #Assuming PE 4+
      $gem_provider = 'puppet_gem'
      $group,$user = 'pe-puppet'
      } else {
        #Assume Open Source Pupppet 4
        $gem_provider = 'puppet_gem'
        $user,$group = 'puppet'
      }
    } else {
      #Assume Open Source Puppet 3
      $gem_provider = 'gem'
      $user,$group = 'puppet'
    }
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
