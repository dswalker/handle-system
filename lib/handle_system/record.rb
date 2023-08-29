# frozen_string_literal: true

module HandleSystem
  #
  # Handle Record entry
  #
  # @author David Walker
  #
  class Record
    # @return [Hash] the internal hash data
    attr_reader :data

    # @return [String] handle identifier
    attr_reader :handle

    # @return [String] the url we registered
    attr_reader :url

    # @return [String] email address added to record
    attr_reader :email

    # @return [String] handle administrator
    attr_reader :hs_admin

    #
    # Populate Record from values
    #
    # @param [String] handle    e.g., 20.500.12345/876
    # @param [String] url       the url we want to register
    # @param [String] email     [optional] email address to add to record
    # @param [String] hs_admin  [optional] handle administrator to add to record
    #
    # @return [self]
    #
    def from_values(handle, url, email = nil, hs_admin = nil)
      @handle = handle
      @url = url
      @email = email
      @hs_admin = hs_admin

      values = [build_url_field(url)]
      values.push(build_email_field(email)) unless email.nil?
      values.push(build_admin_field(hs_admin)) unless hs_admin.nil?
      @data = {
        'values': values,
        'handle': handle,
        'responseCode': 1
      }
      self
    end

    #
    # Populate Record from JSON
    #
    # @param json [JSON]  the handle server record as json
    #
    # @return [self]
    #
    def from_json(json)
      @data = json
      @handle = json['handle']
      json['values'].each do |part|
        value = part['data']['value']
        @url = value if part['type'] == 'URL'
        @has_admin = value if part['type'] == 'EMAIL'
        @email = value if part['type'] == 'HS_ADMIN'
      end
      self
    end

    #
    # @return [<String>] JSON string
    #
    def json
      @data.to_json
    end

    private

    #
    # Current date-time
    #
    # @return [String]
    #
    def timestamp
      DateTime.now.strftime('%Y-%m-%dT%H:%M:%SZ')
    end

    #
    # Create a new URL field
    #
    # @param [String] url  the url we want to register
    #
    # @return [Hash]
    #
    def build_url_field(url)
      {
        'index': 1,
        'ttl': 86_400,
        'type': 'URL',
        'timestamp': timestamp,
        'data': {
          'value': url,
          'format': 'string'
        }
      }
    end

    #
    # Create a new EMAIL field
    #
    # @param [String] email  email address
    #
    # @return [Hash]
    #
    def build_email_field(email)
      {
        'index': 2,
        'ttl': 86_400,
        'type': 'EMAIL',
        'timestamp': timestamp,
        'data': {
          'value': email,
          'format': 'string'
        }
      }
    end

    #
    # Create a new HS_ADMIN field
    #
    # @param [String] hs_admin  handle administrator
    #
    # @return [Hash]
    #
    def build_admin_field(hs_admin)
      {
        'index': 100,
        'ttl': 86_400,
        'type': 'HS_ADMIN',
        'timestamp': timestamp,
        'data': {
          'value': {
            'index': 200,
            'handle': hs_admin,
            'permissions': '011111110011'
          },
          'format': 'admin'
        }
      }
    end
  end
end
