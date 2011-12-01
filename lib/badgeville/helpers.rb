module Badgeville
  module Helpers
    def property_params(object_name, params)
      params.inject({}) do |new_params, entry|
        k, v = entry
        new_params["#{object_name.to_s}[#{k.to_s}]"] = v
        new_params
      end
    end

    def ensure_array(items)
      items.is_a?(Array) ? items : [items]
    end
  end
end
