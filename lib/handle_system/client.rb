# frozen_string_literal: true

module HandleSystem
  #
  # Handle System client
  #
  # @author David Walker
  #
  class Client
    #
    # New Handle System client
    #
    # @param [String] server         ip_address:port, e.g., 123.456.78.9:8000
    # @param [String] hs_admin       handle administrator
    # @param [String] priv_key_path  file path to private key
    # @param [String] pass_phrase    [optional] pass phrase for private key
    #
    def initialize(server, hs_admin, priv_key_path, pass_phrase = nil)
      @http_client = HttpClient.new(server, hs_admin, priv_key_path, pass_phrase)
      @handle_base = 'http://hdl.handle.net/'
    end

    #
    # Create a new handle
    #
    # @param [String] handle    e.g., 20.500.12345/876
    # @param [String] url       the url we want to register
    # @param [String] email     [optional] email address to add to record
    # @param [String] hs_admin  [optional] handle administrator to add to record
    #
    # @return [string] the new handle url at hdl.handle.net
    #
    def create(handle, url, email = nil, hs_admin = nil)
      body = Record.new.from_values(handle, url, email, hs_admin).json
      json = @http_client.put_it('/handles/' + handle, body)
      @handle_base + json['handle']
    end

    # creating and updating handle records is the same thing
    alias update create

    #
    # Return the full record for a handle
    #
    # @param [String] handle  handle identifier
    #
    # @return [<JSON>] the handle record
    #
    def get(handle)
      json = @http_client.get_it('/handles/' + handle)
      Record.new.from_json(json)
    end

    #
    # Delete a handle
    #
    # @param [String] handle  handle identifier
    #
    # @return [Boolean] true if we deleted the record
    #
    def delete(handle)
      json = @http_client.delete_it('/handles/' + handle)
      return true if json['responseCode'] == 1
    end
  end
end
