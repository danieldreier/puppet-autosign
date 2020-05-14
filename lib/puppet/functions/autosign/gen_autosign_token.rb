# @summary
#    Generate a JWT autosign token for use with the autosign gem's
#    autosign policy executable.
#
#    Requires a hostname string as input. Token validity, the secret
#    used to sign the token, and other settings are determined by settings in
#    autosign.conf.
#
#
# @param certname
#   The certname to sign.  Can also be a regex to accept multiple certnames
#
# @param jwt_token_validity
#   The token validity time is seconds
#
# @return [String] - the token value
#
# @example usage with the certname to get a token for
#   autosign::gen_autosign_token('puppet.vm')
#     => eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJkYXRhIjoie1wiY2VydG5hbWVcIjpcIjBm
# @example  Certname and validity time
#   autosign::gen_autosign_token('puppet.vm', 7200)
#     => eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJkYXRhIjoie1wiY2VydG5hbWVcIjpcIjBm
# @example Using a regex instead of a certname
#   autosign::gen_autosign_token('*.puppet.vm')
#     => eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJkYXRhIjoie1wiY2VydG5hbWVcIjpcIjBm
Puppet::Functions.create_function(:'autosign::gen_autosign_token') do
  dispatch :with_validity_time do
    param 'String', :certname
    param 'Integer', :jwt_token_validity
  end

  dispatch :without_validity_time do
    param 'String', :certname
  end

  def with_validity_time(certname, jwt_token_validity)
    generate_token(certname, jwt_token_validity)
  end

  def without_validity_time(certname)
    generate_token(certname)
  end

  def generate_token(certname, jwt_token_validity = nil)
    begin
      require 'autosign'
      require 'socket'
      require 'logging'
    rescue LoadError
      raise(Puppet::Error, "Attempting to use autosign::gen_autosign_token() without the autosign gem.\nPlease run: puppetserver gem install autosign")
    end

    @logger = Logging.logger['Autosign']
    @logger.level = :info
    @logger.add_appenders Logging.appenders.stdout
    config = Autosign::Config.new
    jwt_token_validity ||= config.settings['jwt_token'].fetch('validity', 7200)

    jwt_secret = ENV['JWT_TOKEN_SECRET'] || config.settings['jwt_token']['secret']

    if jwt_secret.nil?
      raise(Puppet::ParseError, 'autosign::gen_autosign_token(): cannot generate token. ' \
            'No secret provided in /etc/autosign.conf or JWT_TOKEN_SECRET env variable')
    end

    token = Autosign::Token.new(certname, false, jwt_token_validity.to_i, Socket.gethostname.to_s, jwt_secret)
    token.sign
  end
end
