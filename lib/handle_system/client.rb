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
    # @param [String] email     [optional] email address
    # @param [String] hs_admin  [optional] handle administrator
    #
    # @return [string] the new handle url at hdl.handle.net
    #
    def create(handle, url, email = nil, hs_admin = nil)
      set_record(handle, url, email, hs_admin, false)
    end

    #
    # Update an existing handle
    #
    # Will create a new handle if no record already exists
    #
    # @param [String] handle    e.g., 20.500.12345/876
    # @param [String] url       the url we want to register
    # @param [String] email     [optional] email address
    # @param [String] hs_admin  [optional] handle administrator
    #
    # @return [string] the new handle url at hdl.handle.net
    #
    def update(handle, url, email = nil, hs_admin = nil)
      set_record(handle, url, email, hs_admin, true)
    end

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

    protected

    #
    # Create or update a handle
    #
    # @param [String] handle     e.g., 20.500.12345/876
    # @param [String] url        the url we want to register
    # @param [String] email      [optional] email address to add to record
    # @param [String] hs_admin   [optional] handle administrator
    # @param [Boolean] overwrite [optional] overwrite any existing record?
    #                              default: false
    #
    # @return [string] the new handle url at hdl.handle.net
    #
    def set_record(handle, url, email = nil, hs_admin = nil, overwrite = false)
      body = Record.new.from_values(handle, url, email, hs_admin).json
      url = '/handles/' + handle + '?overwrite=' + overwrite.to_s
      json = @http_client.put(url, body)
      @handle_base + json['handle']
    end
  end
end
