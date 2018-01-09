# == Class autosign::config
#
# This class is called from autosign for service config.
#
class autosign::config {
  $config_ensure = $::autosign::ensure ? {
      /(absent|purged)/ => 'absent',
      default           => 'present',
  }

  $settings = deep_merge($::autosign::params::settings, $::autosign::settings)

  file {$::autosign::configfile:
    ensure  => $config_ensure,
    mode    => '0640',
    content => template('autosign/autosign.conf.erb'),
    owner   => $::autosign::user,
    group   => $::autosign::group,
  }

  if $::autosign::manage_logfile {
    file {$::autosign::settings['general']['logfile']:
      ensure => 'file',
      mode   => '0640',
      owner  => $::autosign::user,
      group  => $::autosign::group,
    }
  }

  if $::autosign::manage_logfile {
    file {$::autosign::settings['jwt_token']['journalfile']:
      ensure => 'file',
      mode   => '0640',
      owner  => $::autosign::user,
      group  => $::autosign::group,
    }
  }
}
