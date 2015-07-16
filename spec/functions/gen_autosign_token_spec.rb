require 'spec_helper'

# accept a hostname and return a JSON web token, which is three base64
# encoded strings separated by periods
describe 'gen_autosign_token' do
  random_string = rand(36**25).to_s(36)
  ENV['JWT_TOKEN_SECRET'] = rand(36**25).to_s(36)

  context 'accepts a hostname as the parameter' do
    it { should run.with_params(random_string).and_return(/^[^.]+\.[^.]+\.[^.]+$/) }
  end

  context 'accepts a hostname and TTL in seconds as parameters' do
    it { should run.with_params(random_string, rand(10000)).and_return(/^[^.]+\.[^.]+\.[^.]+$/) }
  end

  context 'raises an error given incorrect parameters' do
    it { should run.with_params().and_raise_error(Puppet::ParseError) }
    it { should run.with_params('hostname.example.com', 'not_an_integer').and_raise_error(Puppet::ParseError) }
    it { should run.with_params('hostname.example.com', 3600, 'invalid_third_parameter').and_raise_error(Puppet::ParseError) }
  end
end
