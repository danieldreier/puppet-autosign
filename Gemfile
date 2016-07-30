source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 4.0.0'
  gem "rspec", '< 3.2.0'
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem "listen", '3.0.8'
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
  gem 'puppet_spec_facts'
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
end

gem 'autosign', '>= 0.0.8'
