module Badgeville
  class Reward < Endpoint
    attr_accessor :active, :definition_id, :hint, :id, :message, :name, :tags
    attr_accessor :threshold, :verb

    attr_writer :image_url

    def self.find_by_player_id(player_id)
      get_all_rewards(player_id: player_id)
    end

    def self.find_by_email_and_site(email, site)
      get_all_rewards(email: email, site: site)
    end

    def initialize(json = {})
      @json = json

      if @json
        reward_definition = @json['definition']
        reward_definition ? init_from(reward_definition) : init_from(@json)
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
        rescue Badgeville::NotFound
          []
        end
      end

      def init_from(json)
        ['name', 'active', 'hint', 'image_url', 'message'].each do |key|
          send("#{key}=", json[key])
        end

        @id = @definition_id = json['_id']

        if json['data'] && json['type'] == 'achievement'
          @verb      = json['data']['verb']
          @threshold = json['data']['threshold'].to_i
        end

        @tags = json['tags'] || []
      end
  end
end
