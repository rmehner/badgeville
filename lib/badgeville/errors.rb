module Badgeville
  class Error < StandardError
    attr_accessor :original_error

    def initialize(message, error)
      @original_error = error
      super('[Badgeville] ' + message)
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
  class Forbidden < Error
    attr_reader :response
    def initialize(error)
      @response = error.response
      super('Access denied', error)
    end
  end

  # 404
  class NotFound < Error
    attr_reader :response
    def initialize(error)
      @response = error.response
      super('Could not find resource', error)
    end
  end

  # 422
  class Unprocessable < Error
    attr_reader :response
    def initialize(error)
      @response = error.response
      super('Unprocessable entity', error)
    end
  end

  # 500
  class ServerError < Error
    def initialize(error)
      @response = error.response
      super('Internal server error', error)
    end
  end
end
