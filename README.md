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

* Installs the autosign gem
* Manages /etc/autosign.conf (or /usr/local/etc/autosign.conf on BSDs)
* Creates /var/lib/autosign (or /var/autosign on BSDs)

### Setup Requirements

This module does not configure puppet to do policy-based autosigning. See the [autosign gem](https://github.com/danieldreier/autosign#2-configure-master) or [puppet docs](https://docs.puppetlabs.com/puppet/latest/reference/ssl_autosign.html#policy-based-autosigning) for instructions on how to configure policy-based autosigning. In puppet, the configuration will probably look something like:

```puppet
ini_setting {'policy-based autosigning':
  setting => 'autosign',
  path    => "${confdir}/puppet.conf",
  section => 'master',
  value   => '/usr/local/bin/autosign-validator',
}
```

Note that if you're using the new AIO packaging, the path will probably be `/opt/puppetlabs/puppet/bin/autosign-validator` because it should be installed using the version of ruby bundled with Puppet. Puppet Enterprise will probably put it in `/opt/puppet/bin/autosign-validator`.

### Beginning with autosign

#### Install Module
```bash
puppet module install danieldreier-autosign
```

#### Basic manifest
A Basic configuration might look like the following. Do not use the default password!

```puppet
ini_setting {'policy-based autosigning':
  setting => 'autosign',
  path    => "${confdir}/puppet.conf",
  section => 'master',
  value   => '/usr/local/bin/autosign-validator',
  notify  => Service['puppetmaster'],
}

class { ::autosign:
  ensure   => 'latest',
  settings => {
    'general' => {
      'loglevel' => 'INFO',
    }
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

## Development

Contributions are welcome. New functionality must have passing rspec test
coverage in the PR, and should ideally also have beaker test coverage for
major new functionality.

For the time being, this module will remain compatible with both Puppet 3.x
and 4.x. In the next 6-12 months, it will probably become a 4.x-only module.

The primary development targets for this module are Puppet 3.x on Debian
Wheezy, CentOS 7, and FreeBSD 10. New functionality that requires updates to
`params.pp` should include relevant data for each of these platforms. If
you want support for other platforms, please include test coverage in the PR.

To contribute improvements, please fork this repository, create a feature
branch off your fork, and add the code there. Once your tests pass locally,
make a pull request and check that tests pass on CI, which probably tests a
wider range of puppet and ruby versions than you have locally.
