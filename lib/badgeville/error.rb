module Badgeville
  class BadgevilleError < StandardError
    attr_accessor :code, :data

    def initialize (err_code=nil, error_data="")
      super error_data.to_s
      @data = error_data
      @code = err_code
    end

    def to_s
      "ERROR #{@code} : #{@data}"
    end
  end
end
