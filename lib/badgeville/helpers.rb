module Badgeville
  module Helpers
    def ensure_array(items)
      items.is_a?(Array) ? items : [items]
    end
  end
end
