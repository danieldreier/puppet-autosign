#!/bin/bash

# Locations to look for the autosign executable
executables=(
    '/opt/puppetlabs/puppet/bin/autosign'
    '/opt/puppet/bin/autosign'
    '/usr/local/bin/autosign'
)

# Look for the executable and pick the first one we find
autosign="unknown"
for executable in "${executables[@]}"
do
    if [[ -x "$executable" ]] ; then
        autosign=$executable
    fi
done

# If we couldn't find an execuatble exit with a nice error
if [ "$autosign" = "unknown" ] ; then
    (>&2 echo "Autosign executable could not be found. Is this the Puppet master?")
    exit 1
fi

command=(
    $autosign
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
