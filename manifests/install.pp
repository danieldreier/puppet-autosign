# == Class autosign::install
#
# This class is called from autosign for install.
#
class autosign::install {

  # install the autosign gem
  if $::autosign::manage_package {
    package {
      default:
        name   => $::autosign::package_name,
        source => $::autosign::gem_source
      ;
      'autosign via puppet_gem':
        ensure   => $::autosign::ensure,
        provider => $::autosign::gem_provider,
      ;
      'autosign via puppetserver_gem':
        ensure   => $::autosign::puppetserver_ensure,
        provider => 'puppetserver_gem',
      ;
    }
  }

  $dir_ensure = $::autosign::ensure ? {
      /(absent|purged)/ => 'absent',
      default           => 'directory',
  }

  if $::autosign::manage_journalfile {
    # the autosign key journal stores previously-used tokens to prevent re-use
    file {$::autosign::journalpath:
      ensure => $dir_ensure,
      mode   => '0750',
      owner  => $::autosign::user,
      group  => $::autosign::group,
    }
  }
}
