require 'puppetlabs_spec_helper/module_spec_helper'
require 'puppet_spec_facts'
include PuppetSpecFacts

RSpec.configure do |c|
  c.default_facts = {
    is_pe: false,
    puppetversion: Puppet.version,
    pe_server_version: '2016.2',
  }
end
