module Badgeville
  class Error < StandardError
    attr_accessor :original_error

    def initialize(message, error)
      @original_error = error
      super('[Badgeville] ' + message)
    end
  end

  class ErrorWithResponse < Error
    attr_reader :response
    def initialize(message, error)
      @response = error.response
      super(message, error)
    end
  end

  # deprecated old error
  class BadgevilleError < Error
    attr_accessor :code
    alias :data :original_error

    def initialize(error_code = nil, data = nil)
      super(data.to_s, data)
      @code = error_code
    end
  end

  # Timeout
  class NotAvailable < Error
    def initialize(error)
      super('Service is currently not available', error)
    end
  end

  # invalid JSON returned etc.
  class ParseError < Error
    def initialize(error)
      super('JSON could not be parsed: ' + error.message, error)
    end
  end

  # 403
  class Forbidden < ErrorWithResponse
    def initialize(error)
      super('Access denied', error)
    end
  end

  # 404
  class NotFound < ErrorWithResponse
    def initialize(error)
      super('Could not find resource', error)
    end
  end

  # 422
  class Unprocessable < ErrorWithResponse
    def initialize(error)
      super('Unprocessable entity', error)
    end
  end

  # 500
  class ServerError < ErrorWithResponse
    def initialize(error)
      super('Internal server error', error)
    end
  end
end
