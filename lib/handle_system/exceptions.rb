# frozen_string_literal: true

module HandleSystem
  #
  # A basic Exception class to wrap the handle server errors
  #
  # @author David Walker
  #
  class Error < StandardError
    # @return [Intenger] handle protocol response code for the message
    attr_reader :response_code

    # @return [String] the handle specified in the request
    attr_accessor :handle

    # @return [String] the URL we sent that produced the error
    attr_accessor :url

    #
    # New Handle server Error
    #
    # @param [Integer] response_code  handle protocol response code for the message
    # @param [String] message         error message
    #
    def initialize(response_code, message)
      @response_code = response_code.to_int unless response_code.nil?
      super(message)
    end

    #
    # Handle server response codes / description
    #
    # @return [Hash]  in the form of code => description
    #
    def self.response_codes
      {
        2 => 'An unexpected error on the server',
        100 => 'Handle not found',
        101 => 'Handle already exists',
        102 => 'Invalid handle',
        200 => 'Values not found',
        201 => 'Value already exists',
        202 => 'Invalid value',
        301 => 'Server not responsible for handle',
        402 => 'Authentication needed'
      }
    end
  end

  #
  # Handle server authentication error
  #
  # @author David Walker
  #
  class AuthenticationError < StandardError; end
end
