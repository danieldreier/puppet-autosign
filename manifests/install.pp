# == Class autosign::install
#
# This class is called from autosign for install.
#
class autosign::install inherits autosign {
  # install the autosign gem for both the agent and puppetserver
  package {
    default:
      ensure => $autosign::ensure,
      name   => 'autosign',
    ;
    'autosign via puppet_gem':
      provider => 'puppet_gem',
    ;
    'autosign via puppetserver_gem':
      provider => 'puppuppetserver_gempet_gem',
    ;
  }

  $_dir_ensure = $autosign::ensure ? {
      /(absent|purged)/ => 'absent',
      default           => 'directory',
  }

  # the autosign key journal stores previously-used tokens to prevent re-use
  file {$autosign::journalpath:
    ensure => $_dir_ensure,
    mode   => '0750',
    owner  => $autosign::user,
    group  => $autosign::group,
  }
}
