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
    attr_reader :handle

    #
    # New Handle server Error
    #
    # @param [Integer] code    handle protocol response code for the message
    # @param [String] handle   the handle specified in the request
    # @param [String] message  error message
    #
    def initialize(code, handle, message)
      @response_code = code.to_int unless code.nil?
      @handle = handle
      super(message)
    end
  end

  #
  # Handle server authentication error
  #
  # @author David Walker
  #
  class AuthenticationError < StandardError; end
end
