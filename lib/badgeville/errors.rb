module Badgeville
  class Error < StandardError
    attr_accessor :data

    def initialize(data)
      @data = data
    end
  end

  # deprecated old error
  class BadgevilleError < Error
    attr_accessor :code

    def initialize(error_code = nil, data = nil)
      super(data.to_s)
      @code = error_code
    end
  end

  # Timeout
  class NotAvailable < Error; end

  # invalid JSON returned etc.
  class ParseError < Error; end

  # 403
  class Forbidden < Error; end

  # 404
  class NotFound < Error; end

  # 500
  class ServerError < Error; end

end
