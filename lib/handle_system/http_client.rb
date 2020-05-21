# frozen_string_literal: true

require 'base64'
require 'httparty'
require 'securerandom'

module HandleSystem
  #
  # HTTP utility class for Handle client
  #
  # Provides some convenience methods so we don't have to set headers and
  # options with each request, checks for and throws errors reported by
  # the handle server, and does the work of acquiring a session
  #
  # @author David Walker
  #
  class HttpClient
    include HTTParty

    #
    # New Handle HTTP client
    #
    # @param [String] server         ip_address:port, e.g., 123.456.78.9:8000
    # @param [String] hs_admin       handle administrator
    # @param [String] priv_key_path  file path to private key
    # @param [String] pass_phrase    [optional] pass phrase for private key
    #
    def initialize(server, hs_admin, priv_key_path, pass_phrase = nil)
      @hs_admin = hs_admin
      @private_key_path = priv_key_path
      @pass_phrase = pass_phrase
      @base_url = 'https://' + server + '/api'
      @session_id = initialize_session
    end

    #
    # Send a get request
    #
    # @param [String] path  relative path from /api end-point
    #
    # @raise HandleSystem::Error  if we got an error from the server
    # @return [JSON]      parsed json response from handle server
    #
    def get_it(path)
      url = @base_url + path
      json = self.class.get(url, options).parsed_response
      check_errors(json)
      json
    end

    #
    # Send a put request
    #
    # @param [String] path  relative path from /api end-point
    # @param [String] body  json data object
    #
    # @raise HandleSystem::Error  if we got an error from the server
    # @return [JSON]      parsed json response from handle server
    #
    def put_it(path, body)
      url = @base_url + path
      json = self.class.put(url, body: body, **options).parsed_response
      check_errors(json)
      json
    end

    #
    # Send a delete request
    #
    # @param [String] path  relative path from /api end-point
    #
    # @raise HandleSystem::Error  if we got an error from the server
    # @return [JSON]      parsed json response from handle server
    #
    def delete_it(path)
      url = @base_url + path
      json = self.class.delete(url, options).parsed_response
      check_errors(json)
      json
    end

    private

    #
    # Header and connection options
    #
    # @raise HandleSystem::Error
    # @return [Hash]
    #
    def options
      {
        headers: {
          'Content-Type': 'application/json;charset=UTF-8',
          'Authorization': 'Handle sessionId="' + @session_id + '"'
        },
        verify: false
      }
    end

    #
    # If we got an error message from the handle server, convert it into
    # an actual exception and throw it here
    #
    # @param [JSON] json  handle server json response
    # @raise HandleSystem::Error
    #
    def check_errors(json)
      return unless json['message']

      raise Error.new(json['responseCode'], json['handle'], json['message'])
    end

    #
    # Initialize a new session with the handle server using its
    # challenge-response framework
    #
    # @raise AuthenticationError if identity not verified
    #
    # @return [String] the authenticated session id
    #
    def initialize_session
      # get initial challenge from handle server
      url = @base_url + '/sessions/'
      json = self.class.post(url, verify: false).parsed_response
      nounce = Base64.decode64(json['nonce'])
      session_id = json['sessionId']

      # create authorization header
      headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': create_auth_header(nounce, session_id)
      }

      # send it back to handle server to get authenticated session id
      opts = { headers: headers, verify: false }
      json = self.class.put(url + 'this', opts).parsed_response
      raise AuthenticationError, json['error'] unless json['authenticated']

      json['sessionId']
    end

    #
    # Create authentication header
    #
    # @param [String] server_nonce  nonce from handle server
    # @param [String] session_id    session identifier from handle server
    #
    # @return [String] handle authorization header
    #
    def create_auth_header(server_nonce, session_id)
      # challenge response is combination of server's nonce and
      # client nonce that we will create ourselves
      client_nonce = SecureRandom.random_bytes(16)
      combined_nonce = server_nonce + client_nonce

      # create combined nonce digest and sign with private key
      key_file = File.read(@private_key_path)
      private_key = OpenSSL::PKey::RSA.new(key_file, @pass_phrase)
      signature = private_key.sign(OpenSSL::Digest::SHA256.new, combined_nonce)

      # build the authorization header
      header = 'Handle sessionId="' + session_id + '", ' \
              'id="' + CGI.escape(@hs_admin) + '", ' \
              'type="HS_PUBKEY", ' \
              'cnonce="' + Base64.encode64(client_nonce) + '", ' \
              'alg="SHA256", ' \
              'signature="' + Base64.encode64(signature) + '"'
      header.gsub("\n", '')
    end
  end
end
