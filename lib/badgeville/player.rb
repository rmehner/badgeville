module Badgeville
  class Player < Endpoint
    ATTRIBUTES = [
      :email, :first_name, :last_name, :display_name, :nick_name, :user_email,
      :user_id, :site_id, :site_url, :facebook_id, :facebook_link, :twitter_id,
      :twitter_username, :twitter_link, :custom_picture_url, :picture_url,
      :preferences, :teams, :units
    ]

    ATTRIBUTES.each do |attr|
      attr_accessor attr
    end

    class << self
      def create(attributes)
        if !attributes[:email] || !attributes[:site]
          raise ArgumentError.new('You have to provide email and site')
        end

        response = client.post(
          'players.json',
          {
            email: attributes.delete(:email),
            site: attributes.delete(:site)
          }.merge(player: attributes)
        )

        new(response)
      end

      def find_by_email_and_site(email, site)
        begin
          response = client.get('/players/info.json', {email: email, site: site})
          new(response)
        rescue NotFound
        end
      end

      def find_by_id(id)
        begin
          response = client.get("/players/#{id}.json")
          new(response)
        rescue NotFound
        end
      end

      def update(id, attributes = {})
        client.put("/players/#{id}.json", player: attributes)
      end

      def delete(id)
        client.delete("/players/#{id}.json")
      end
    end

    def initialize(attributes = {})
      @attributes = attributes

      ATTRIBUTES.each do |attr|
        self.send("#{attr}=", @attributes[attr.to_s])
      end
    end

    def created_at
      @created_at ||= Time.parse(@attributes['created_at'])
    end

    def id
      @attributes['_id']
    end
  end
end
