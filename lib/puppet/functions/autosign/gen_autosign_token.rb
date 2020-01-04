# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----
require 'autosign'
require 'socket'
require 'logging'

# ---- original file header ----
#
# @summary
#       Generate a JWT autosign token for use with the autosign gem's
#    autosign policy executable.
#
#    Requires a boolean hostname string as input. Token validity, the secret
#    used to sign the token, and other settings are determined by settings in
#    autosign.conf.
#
#
Puppet::Functions.create_function(:'autosign::gen_autosign_token') do
  # @param arguments
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :arguments
  end


  def default_impl(*arguments)
    
    @logger = Logging.logger['Autosign']
    @logger.level = :info
    @logger.add_appenders Logging.appenders.stdout

    config = Autosign::Config.new()
    case arguments.size
    when 1
      jwt_token_validity = config.settings['jwt_token']['validity']
    when 2
      raise(Puppet::ParseError, "gen_autosign_token(): second argument must be a positive integer") unless arguments[1].to_i > 0
      jwt_token_validity = arguments[1].to_i
    else
      raise(Puppet::ParseError, "gen_autosign_token(): Wrong number of arguments " +
      "given (#{arguments.size} for 1 or 2)")
    end

    jwt_secret = ENV['JWT_TOKEN_SECRET'] unless ENV['JWT_TOKEN_SECRET'].nil?
    jwt_secret = config.settings['jwt_token']['secret'] unless config.settings['jwt_token']['secret'].nil?

    if jwt_secret.nil?
      raise(Puppet::ParseError, "gen_autosign_token(): cannot generate token. " +
            "No secret provided in /etc/autosign.conf or JWT_TOKEN_SECRET env variable")
    end

    token = Autosign::Token.new(arguments[0].to_s, false, jwt_token_validity.to_i, Socket.gethostname.to_s, jwt_secret)

    #value = function_str2bool([arguments[0]])

    # We have real boolean values as well ...
    result = token.sign

    return result
  
  end
end
