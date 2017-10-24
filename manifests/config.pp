# == Class autosign::config
#
# This class is called from autosign for service config.
#
class autosign::config {
  $_config_ensure = $autosign::ensure ? {
      /(absent|purged)/ => 'absent',
      default           => 'present',
  }

  file {$::autosign::configfile:
    ensure  => $_config_ensure,
    mode    => '0640',
    content => epp('autosign/autosign.conf.epp', {
      'loglevel'    => $autosign::settings_loglevel,
      'logfile'     => $autosign::settings_logfile,
      'validity'    => $autosign::settings_validity,
      'journalpath' => $autosign::journalpath,
      'journalfile' => $autosign::settings_journalfile,
    }),
    owner   => $autosign::user,
    group   => $autosign::group,
  }
}
