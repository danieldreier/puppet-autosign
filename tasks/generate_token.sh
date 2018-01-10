#!/bin/bash

PATH="/opt/puppetlabs/puppetserver/bin:/opt/puppetlabs/puppet/bin:/opt/puppet/bin:/usr/local/bin:$PATH"


# If we couldn't find an execuatble exit with a nice error
if ! command -v autosign > /dev/null 2>&1 ; then
    (>&2 echo "Autosign executable could not be found. Is this the Puppet master?")
    exit 1
fi

command=(
    autosign
    generate
    --bare
)

# Set the token ot be reusable if required
if [ "$PT_reusable" = "true" ] ; then
    command+=('--reusable')
else
    command+=('--no-reusable')
fi

# Set the validity if required
if [ "$PT_validfor" -gt "0" ]; then
    command+=("--validfor=$PT_validfor")
fi

# Add the certname/regex
command+=("$PT_certname")


eval ${command[@]}
