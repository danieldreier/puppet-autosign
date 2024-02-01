# == Class autosign::config
#
# This class is called from autosign for service config.
#
class autosign::config {
  $config_ensure = $autosign::ensure ? {
    /(absent|purged)/ => 'absent',
    default           => 'file',
  }
  # due to maintaining backwards compatability 
  # we need to conditionally unwrap the sensitive value
  # before we goto merge it with another hash.
  if $autosign::config =~ Sensitive {
    $unwrapped_config = $autosign::config.unwrap
  } else {
    $unwrapped_config = $autosign::config
  }
  # merge the two unwrapped values together
  $settings = deep_merge($autosign::params::config.unwrap, $unwrapped_config)

  $sensitive_config = Sensitive(epp('autosign/autosign.conf.epp', { settings => $settings }))

  # Ensure we set the value to Sensitive so the secrets don't get revealed
  file { $autosign::configfile:
    ensure  => $config_ensure,
    mode    => '0640',
    content => $sensitive_config,
    owner   => $autosign::user,
    group   => $autosign::group,
  }

  if $autosign::manage_logfile {
    file { $settings['general']['logfile']:
      ensure => 'file',
      mode   => '0640',
      owner  => $autosign::user,
      group  => $autosign::group,
    }
  }

  if $autosign::manage_journalfile {
    file { $settings['jwt_token']['journalfile']:
      ensure => 'file',
      mode   => '0640',
      owner  => $autosign::user,
      group  => $autosign::group,
    }
  }
}
