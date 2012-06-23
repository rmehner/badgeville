module Badgeville
  class Reward < Endpoint
    ATTRIBUTES = [
      :active, :definition, :definition_id, :hint, :id, :image_url, :message, :name,
      :position, :start_points, :tags, :threshold, :type, :verb
    ]

    ATTRIBUTES.each do |attr|
      attr_accessor attr
    end

    class << self
      def find_by_player_id(player_id)
        get_all_rewards(player_id: player_id)
      end

      def find_by_email_and_site(email, site)
        get_all_rewards(email: email, site: site)
      end
    end

    def initialize(json = {})
      @json = json

      if @json
        self.definition = @json['definition']
        definition ? init_from(definition) : init_from(@json)
        @id = json['id'] if @json.has_key?('user_id')
      end
    end

    def earned_at
      if @json.has_key?('user_id') && !@earned_at
        @earned_at = DateTime.parse(@json['created_at']).to_time
      end

      @earned_at
    end

    def image_url(format = :original)
      @image_url.sub('original', format.to_s).sub(/^https?:/, '') if @image_url
    end

    private

      def self.get_all_rewards(player_info)
        begin
          response = client.get_all('rewards.json', player_info)
          response.inject([]) do |rewards, reward|
            rewards << new(reward)
          end
        rescue NotFound
          []
        end
      end

      def init_from(json)
        ['name', 'active', 'hint', 'image_url', 'message', 'type'].each do |key|
          send("#{key}=", json[key])
        end

        @id = @definition_id = json['_id']

        if json['data'] && json['type'] == 'achievement'
          @verb      = json['data']['verb']
          @threshold = json['data']['threshold'].to_i
        end

        if json['data'] && json['type'] == 'level'
          @position     = json['data']['position'].to_i
          @start_points = json['data']['start_points'].to_i
        end

        @tags = json['tags'] || []
      end
  end
end
