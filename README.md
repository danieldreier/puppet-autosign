[![Build Status](https://travis-ci.org/danieldreier/puppet-autosign.svg?branch=master)](https://travis-ci.org/danieldreier/puppet-autosign) [![Puppet Forge](https://img.shields.io/puppetforge/dt/danieldreier/autosign.svg)](https://forge.puppetlabs.com/danieldreier/autosign) [![Puppet Forge](https://img.shields.io/puppetforge/v/danieldreier/autosign.svg)](https://forge.puppetlabs.com/danieldreier/autosign)

## Overview

This module manages the [autosign gem](https://github.com/danieldreier/autosign), which facilitates [policy-based certificate signing](https://docs.puppetlabs.com/puppet/latest/reference/ssl_autosign.html#policy-based-autosigning) in Puppet.

## Description

This module:

- installs and configures the [autosign gem](https://github.com/danieldreier/autosign)
- provides a puppet function to generate JWT tokens for autosigning, for example when provisioning VMs using Puppet

## Setup

#### Install
```
puppet module install danieldreier-autosign
```

### What autosign affects

  - Installs the autosign gem
  - Manages the autosign config file
    - `/etc/puppetlabs/puppetserver/autosign.conf` *Puppet Enterprise*
    - `/etc/autosign.conf` *Linux*
    - `/usr/local/etc/autosign.conf` *BSDs*
  - Creates journalfile and parent directory
    - `/opt/puppetlabs/server/autosign/autosign.journal` *Puppet Enterprise*
    - `/var/lib/autosign/autosign.journal` *Linux*
    - `/var/autosign/autosign.journal` *BSDs*
  - Manages logfile permissions
    - `/var/log/puppetlabs/puppetserver/autosign.log` *Puppet Enterprise*
    - `/var/log/autosign.log` *Linux*
    - `/var/log/autosign.log` *BSDs*

### Setup Requirements

This module does not configure puppet to do policy-based autosigning. See the [autosign gem](https://github.com/danieldreier/autosign#2-configure-master) or [puppet docs](https://docs.puppetlabs.com/puppet/latest/reference/ssl_autosign.html#policy-based-autosigning) for instructions on how to configure policy-based autosigning. In puppet, the configuration will probably look something like:

```puppet
ini_setting {'policy-based autosigning':
  setting => 'autosign',
  path    => "${confdir}/puppet.conf",
  section => 'master',
  value   => '/opt/puppetlabs/puppet/bin/autosign-validator',
}
```

### Beginning with autosign

#### Install Module
```bash
puppet module install danieldreier-autosign
```

#### Basic manifest

A Basic configuration might look like the following. Do not use the default password!

```puppet
ini_setting { 'policy-based autosigning':
  setting => 'autosign',
  path    => "${confdir}/puppet.conf",
  section => 'master',
  value   => '/opt/puppetlabs/puppet/bin/autosign-validator',
  notify  => Service['pe-puppetserver'],
}

class { ::autosign:
  ensure => 'latest',
  config => {
    'general' => {
      'loglevel' => 'INFO',
    },
    'jwt_token' => {
      'secret'   => 'hunter2'
      'validity' => '7200',
    }
  },
}
```

## Usage

The `gen_autosign_token` function allows you to generate temporary autosign
tokens in puppet. The syntax is:

```puppet
# return a one-time token that is only valid for the foo.example.com certname
# for the default validity as configured above.
gen_autosign_token('foo.example.com')

# return a one-time token that is only valid for foo.example.com for the
# next 3600 seconds.
gen_autosign_token('foo.example.com', 3600)

# return a one-time token that is valid for any certname matching the regex
# ^.*\.example\.com$ for the default validity period.
gen_autosign_token('/^.*\.example\.com$/')

# return a one-time token that is valid for any certname matching the regex
# ^.*\.example\.com$ for the next week (604800 seconds).
gen_autosign_token('/.*\.example\.com/', 604800)
```

Each of these will return a string which should be added to the
`csr_attributes.yaml` file by your puppet-based provisioning system. For
example, you might use an erb template to generate a cloudinit script that
creates the `csr_attributes.yaml` file.

Note that certnames in puppet do not necessarily correspond to hostnames, so
you should use regex matching to enforce certname policies rather than
attempting to restrict access to infrastructure by certname. A host named
`foo.example.com` can request a certificate for `bar.example.com` and the
master does not care.

### Generating tokens using tasks

This module comes with the `generate_token` task which uses the `autosign generate` command to generate new tokens. This task is designed to make integration with automated and manual provisioning methods easier for Puppet Enterprise users as humans or services can make a request for a token using their LDAP integrated user account instead of having to SSH in to the Puppet Master. Access to this task can be controlled via the Puppet Enterprise RBAC mechanism allowing for much easier control of user access.

Users wishing to generate tokens this way should run the task against the Puppet master and will receive the signing token as the result of the task. Running the `generate_token` task against any other node will fail.

## Classes

### `autosign`

#### Parameters

`package_name`: Name of the gem to install. Defaults to "autosign" and there's probably no reason to override it.

`ensure`: Ensure parameter on the package to install. Set to "present", "latest", "absent", or a specific gem version.

`configfile`: Path to the config file

`user`: User that should own the files, this should be user that the Puppet server runs as.

`group`: Group that should own the config files

`journalpath`: Path to the journalfile, this will be managed as a directory, with the journalfile placed under it.

`gem_provider`: Provide to use to the gem.

`manage_journalfile`: Weather or not to manage the journalfile

`manage_logfile`: Weather or not to manage the logfile

`config`: Hash of config to use.


## Development

Contributions are welcome. New functionality must have passing rspec test
coverage in the PR, and should ideally also have beaker test coverage for
major new functionality.

The primary development targets for this module are Puppet >= 4.x on Debian
Wheezy, CentOS 7, and FreeBSD 10. New functionality that requires updates to
`params.pp` should include relevant data for each of these platforms. If
you want support for other platforms, please include test coverage in the PR.

To contribute improvements, please fork this repository, create a feature
branch off your fork, and add the code there. Once your tests pass locally,
make a pull request and check that tests pass on CI, which probably tests a
wider range of puppet and ruby versions than you have locally.
