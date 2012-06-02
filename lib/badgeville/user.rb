module Badgeville
  class User < Endpoint
    ATTRIBUTES = [:email, :name]

    ATTRIBUTES.each do |attr|
      attr_accessor attr
    end

    def self.create(attributes = {})
      response = client.post('users.json', user: attributes)
      new(response)
    end

    def self.find(id_or_email)
      begin
        response = client.get("users/#{id_or_email}.json")
        new(response)
      rescue Badgeville::NotFound
      end
    end

    def initialize(attributes = {})
      @attributes = attributes

      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", @attributes[attr.to_s])
      end
    end

    def id
      @attributes['_id']
    end

    def created_at
      @created_at ||= Time.parse(@attributes['created_at'])
    end
  end
end
